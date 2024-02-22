# ------------------------------
# helm arcocd & external secrets operator deployment
# ------------------------------
terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

locals {
  argocd_version              = "2.10.1"
  argocd_vault_plugin_version = "1.17.0"
}

data "aws_eks_cluster" "cluster" { name = module.eks.cluster_name }
data "aws_eks_cluster_auth" "cluster" { name = module.eks.cluster_name }

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token = data.aws_eks_cluster_auth.cluster.token
    # exec {
    #   api_version = "client.authentication.k8s.io/v1beta1"
    #   args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.id]
    #   command     = "aws"
    # }
  }
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.cluster.token
  # exec {
  #   api_version = "client.authentication.k8s.io/v1beta1"
  #   args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.id]
  #   command     = "aws"
  # }
}


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
              value: "1.17.0"
          command: ["sh", "-c"]
          args:
            - >-
              curl -L https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v1.17.0/argocd-vault-plugin_1.17.0_linux_amd64 -o argocd-vault-plugin &&
              chmod +x argocd-vault-plugin &&
              mv argocd-vault-plugin /custom-tools/
          volumeMounts:
            - name: custom-tools
              mountPath: /custom-tools


      extraContainers:
      - name: avp-helm
        command: [/var/run/argocd/argocd-cmp-server]
        image: quay.io/argoproj/argocd:v2.10.1
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
      
      repoServer:
        serviceAccount:
          annotations:
            eks.amazonaws.com/role-arn: ${module.irsa_role.iam_role_arn}
    EOT
  ]
}


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

