# arcocd
resource "helm_release" "argo" {
  name = "argocd"
  repository = "https://argoproj.gi thub.io/argo-helm"
  chart      = "argo-cd" 
  namespace  = "argo" 
  version    = "5.51.6"

  namespace = "argocd"
  create_namespace = true

  # An option for setting values that I generally use
  values = [jsonencode({
    someKey = "someKEy"
  })]

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "server.extraArgs"
    value = "[--insecure]"
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


