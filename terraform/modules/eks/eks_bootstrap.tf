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
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.gi thub.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "6.0.3"

  create_namespace = true

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "configs.params.\"server.insecure\""
    value = "true"
  }

  set {
    name  = "server.service.nodePort"
    value = "32000"
  }

  set {
    name  = "server.ingress.enabled"
    value = "false"
  }

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

}


resource "kubectl_manifest" "argo_application" {
  depends_on = [helm_release.argocd]
  yaml_body  = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: parent-app
  namespace: argocd
  finalizers:
  - resources-finalizer.argocd.argoproj.io
  annotations:
    argocd.argoproj.io/sync-wave: "0"
spec:
  project: default
  source:
    repoURL: "https://github.com/flamingo1332/wordpress_eks_argo.git"
    targetRevision: HEAD
    path: "setup"
  destination:
    server: "https://kubernetes.default.svc"
    namespace: argocd
  syncPolicy:
    automated:
      selfHeal: false
      prune: false
YAML
}

