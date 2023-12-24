# set up argoCD with terraform
# and install add-ons with it

# arcocd
resource "helm_release" "argo" {
  name       = "argocd"
  repository = "https://argoproj.gi thub.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "5.51.6"

  create_namespace = true

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


# argo namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}



# # cluster autoscaler
# resource "helm_release" "cluster_autoscaler" {
#   name       = "cluster-autoscaler"
#   repository = "https://kubernetes.github.io/autoscaler"
#   chart      = "cluster-autoscaler"
#   version    = "9.9.2" # Use the appropriate chart version

#   namespace = "kube-system"

#   set {
#     name  = "autoDiscovery.clusterName"
#     value = module.eks.cluster_id
#   }

#   set {
#     name  = "awsRegion"
#     value = "ap-northeast-1"
#   }

#   set {
#     name  = "rbac.serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name  = "rbac.serviceAccount.name"
#     value = "cluster-autoscaler"
#   }

#   set {
#     name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = module.cluster_autoscaler_irsa_role.arn
#   }

#   # ... other configurations ...
# }


# external dns


# aws lb controller

resource "helm_release" "aws_load_balancer_controller" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.6.2"

  set {
    name  = "replicaCount"
    value = 1
  }

  set {
    name  = "clusterName"
    value = module.eks.cluster_id
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.aws_load_balancer_controller_irsa_role.iam_role_arn
  }
}