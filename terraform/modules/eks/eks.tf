# terraform {
#   required_providers {
#     kubectl = {
#       source  = "gavinbunney/kubectl"
#       version = ">= 1.7.0"
#     }
#   }
# }

# provider "kubectl" {
#   host                   = data.aws_eks_cluster.cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.cluster.token
#   load_config_file = false
#   # exec {
#   #   api_version = "client.authentication.k8s.io/v1beta1"
#   #   args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.id]
#   #   command     = "aws"
#   # }
# }


data "aws_eks_cluster" "eks" {
  depends_on = [module.eks]
  name       = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  depends_on = [module.eks]
  name       = module.eks.cluster_name
}

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.eks.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.eks.token
# }


provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "${var.project_name}_cluster"
  cluster_version = var.eks_cluster_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access

  enable_irsa = true

  vpc_id     = var.vpc_id
  subnet_ids = var.vpc_private_subnets

  # addon (kube-proxy, vpc-cni, coredns)
  cluster_addons = {
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  # nodes
  eks_managed_node_groups = {
    one = {
      desired_size = var.eks_cluster_desired_size
      min_size     = var.eks_cluster_min_size
      max_size     = var.eks_cluster_max_size
      disk_size    = var.eks_cluster_disk_size

      labels = {
        role = var.eks_cluster_label_role
      }

      instance_types = var.eks_cluster_instance_types
      capacity_type  = var.eks_cluster_capacity_type

      # Add the required tags for Cluster Autoscaler
      tags = {
        "k8s.io/cluster-autoscaler/enabled"                     = "true"
        "k8s.io/cluster-autoscaler/${var.project_name}_cluster" = "true"
      }
    }


  }


  tags = {
    Project     = var.project_name
    Environment = var.env
  }

  # configmap for eks user access
  # configure iam role with configmap and assume that role with iam user
  # create_aws_auth_configmap = true <- this is only intended for scenarios where the configmap does not exist (i.e. - when using only self-managed node groups)
  # manage_aws_auth_configmap = true
  # aws_auth_roles = [
  #   {
  #     rolearn  = module.eks_admins_iam_role.iam_role_arn
  #     username = module.eks_admins_iam_role.iam_role_name
  #     groups   = ["system:masters"]
  #   },
  # ]


  # for aws lb controller
  # caused duplicate error
  # node_security_group_additional_rules = {
  #   ingress_allow_access_from_control_plane = {
  #     type                          = "ingress"
  #     protocol                      = "tcp"
  #     from_port                     = 9443
  #     to_port                       = 9443
  #     source_cluster_security_group = true
  #     description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
  #   }
  # }

}


# eks access role , group, policy, user

# module "allow_eks_access_iam_policy" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
#   version = "~> 5.0"

#   name          = "allow-wordpress-eks-access"
#   create_policy = true

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "eks:DescribeCluster",
#         ]
#         Effect   = "Allow"
#         Resource = "*"
#       },
#     ]
#   })

#   tags = {
#     Project     = var.project_name
#     Environment = var.env
#   }
# }

# module "eks_admins_iam_role" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
#   version = "~> 5.0"

#   role_name         = "${var.project_name}-admin"
#   create_role       = true
#   role_requires_mfa = false

#   custom_role_policy_arns = [module.allow_eks_access_iam_policy.arn]

#   trusted_role_arns = [
#     "arn:aws:iam::${var.vpc_owner_id}:root"
#   ]
#   tags = {
#     Project     = var.project_name
#     Environment = var.env
#   }
# }

# module "user1_iam_user" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-user"
#   version = "~> 5.0"

#   name                          = "user1"
#   create_iam_access_key         = false
#   create_iam_user_login_profile = false

#   force_destroy = true

#   tags = {
#     Project     = var.project_name
#     Environment = var.env
#   }
# }

# module "allow_assume_eks_admins_iam_policy" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
#   version = "~> 5.0"

#   name          = "allow-assume-eks-admin-iam-role"
#   create_policy = true

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "sts:AssumeRole",
#         ]
#         Effect   = "Allow"
#         Resource = module.eks_admins_iam_role.iam_role_arn
#       },
#     ]
#   })

#   tags = {
#     Project     = var.project_name
#     Environment = var.env
#   }
# }

# module "eks_admins_iam_group" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
#   version = "~> 5.0"

#   name                              = "eks-admin"
#   attach_iam_self_management_policy = false
#   create_group                      = true
#   group_users                       = [module.user1_iam_user.iam_user_name]
#   custom_group_policy_arns          = [module.allow_assume_eks_admins_iam_policy.arn]

#   tags = {
#     Project     = var.project_name
#     Environment = var.env
#   }
# }







