# ------------------------------
# helm arcocd & external secrets operator deployment
# ------------------------------
locals {
  argocd_version = "2.10.1"
  avp_version    = "1.17.0"
}


# Sidecar containers in Kubernetes 1.29 aren't supported with IAM roles for service accounts in the same Pod.
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "6.0.3"

  create_namespace = true

  values = [
    <<-EOT
    configs:
      cmp:
        create: true
        plugins:
          avp-helm:
            allowConcurrency: true
            discover:
              find:
                command:
                  - sh
                  - "-c"
                  - "find . -name 'Chart.yaml' && find . -name 'values.yaml'"
            generate:
              command:
                - bash
                - "-c"
                - |
                  helm template $ARGOCD_APP_NAME -n $ARGOCD_APP_NAMESPACE -f <(echo "$ARGOCD_ENV_HELM_VALUES") . |
                  argocd-vault-plugin generate -
            lockRepo: false


    repoServer:
      volumes:
        - configMap:
            name: argocd-cmp-cm
          name: argocd-cmp-cm
        - name: custom-tools
          emptyDir: {}
        
      initContainers:
        - name: download-tools
          image: registry.access.redhat.com/ubi8
          env:
            - name: AVP_VERSION
              value: "${local.avp_version}"
          command: ["sh", "-c"]
          args:
            - >-
              curl -L https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v${local.avp_version}/argocd-vault-plugin_${local.avp_version}_linux_amd64 -o argocd-vault-plugin &&
              chmod +x argocd-vault-plugin &&
              mv argocd-vault-plugin /custom-tools/
          volumeMounts:
            - name: custom-tools
              mountPath: /custom-tools


      extraContainers:
      - name: avp-helm
        command: [/var/run/argocd/argocd-cmp-server]
        image: quay.io/argoproj/argocd:v${local.argocd_version}
        env:
        - name: AVP_TYPE
          value: awssecretsmanager
        - name: AWS_REGION
          value: ${var.aws_region}
        
        # https://argocd-vault-plugin.readthedocs.io/en/stable/usage/#caveats - need to be increased if lots of placeholders have to be processed for a given Application
        - name: ARGOCD_EXEC_TIMEOUT
          value: "180"
        securityContext:
          runAsNonRoot: true
          runAsUser: 999
        volumeMounts:
          - mountPath: /var/run/argocd
            name: var-files
          - mountPath: /home/argocd/cmp-server/plugins
            name: plugins
          - mountPath: /tmp
            name: tmp
          - mountPath: /home/argocd/cmp-server/config/plugin.yaml
            subPath: avp-helm.yaml
            name: argocd-cmp-cm
          - name: custom-tools
            subPath: argocd-vault-plugin
            mountPath: /usr/local/bin/argocd-vault-plugin 

      serviceAccount:
        automountServiceAccountToken: true
        annotations:
          eks.amazonaws.com/role-arn: ${module.argocd_vault_plugin_irsa_role.iam_role_arn}
      
    EOT
  ]
}



# argocd application manifest
# resource "kubectl_manifest" "argo_application" {
#   depends_on = [helm_release.argocd]
#   yaml_body  = <<YAML
# apiVersion: argoproj.io/v1alpha1
# kind: Application
# metadata:
#   name: parent-app
#   namespace: argocd
#   finalizers:
#   - resources-finalizer.argocd.argoproj.io
#   annotations:
#     argocd.argoproj.io/sync-wave: "0"
# spec:
#   project: default
#   source:
#     repoURL: "https://github.com/flamingo1332/wordpress_eks_argo.git"
#     targetRevision: HEAD
#     path: "setup"
#   destination:
#     server: "https://kubernetes.default.svc"
#     namespace: argocd
#   syncPolicy:
#     automated:
#       selfHeal: false
#       prune: false
# YAML
# }

