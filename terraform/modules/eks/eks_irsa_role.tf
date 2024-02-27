# ------------------------------
# irsa role for extensions
# ------------------------------

#cluster_autoscaler
module "cluster_autoscaler_irsa_role" {
  create_role = true
  source      = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version     = "~> 5.0"

  role_name                        = "cluster-autoscaler"
  attach_cluster_autoscaler_policy = true

  # https://github.com/terraform-aws-modules/terraform-aws-iam/issues/368
  cluster_autoscaler_cluster_ids = [module.eks.cluster_name]

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
  tags = {
    Project     = var.project_name
    Environment = var.env
  }
}


# externalDNS
module "external_dns_irsa_role" {
  create_role = true
  source      = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version     = "~> 5.0"

  role_name                  = "external-dns"
  attach_external_dns_policy = true
  # external_dns_hosted_zone_arns    = 
  external_dns_hosted_zone_arns = [var.hosted_zone_arn]

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }
  tags = {
    Project     = var.project_name
    Environment = var.env
  }
}

# aws lb controller
module "aws_load_balancer_controller_irsa_role" {
  create_role = true
  source      = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version     = "~> 5.0"

  role_name                              = "aws-load-balancer-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = {
    Project     = var.project_name
    Environment = var.env
  }
}

# argocd vault plugin role (for aws secrets manager access)
module "argocd_vault_plugin_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name              = "argocd-vault-plugin"
  allow_self_assume_role = false

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["argocd:argocd-repo-server"]
    }
  }

  role_policy_arns = {
    policy = aws_iam_policy.avp_policy.arn
  }

  tags = {
    Project     = var.project_name
    Environment = var.env
  }
}

resource "aws_iam_policy" "avp_policy" {
  name        = "avp-Policy"
  description = "Policy for argocd vault plugin"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = [aws_secretsmanager_secret.eks_secrets.arn]
      },
    ]
  })

  tags = {
    Project     = var.project_name
    Environment = var.env
  }
}


# wordpress role for db authentication -> need to manually create rds user
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.html
# module "wordpress_irsa_role" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#   role_name              = "wordpress_database_authentication"
#   allow_self_assume_role = false

#   oidc_providers = {
#     one = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["wordpress:wordpress"]
#     }
#   }

#   role_policy_arns = {
#     policy = aws_iam_policy.wordpress_policy.arn
#   }

#   tags = {
#     Project     = var.project_name
#     Environment = var.env
#   }
# }

# resource "aws_iam_policy" "wordpress_policy" {
#   name        = "wordpress-Policy"
#   description = "Policy for wordpress db authentication"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = "rds-db:connect"
#         Resource = "arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${var.db_instance_resource_id}/*"
#       },
#     ]
#   })

#   tags = {
#     Project     = var.project_name
#     Environment = var.env
#   }
# }

# data "aws_caller_identity" "current" {}



# prometheus irsa role(for storing monitoring data on s3)
# module "prometheus_irsa_role" {
#   source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   role_name = "prometheus"

#   role_policy_arns = {
#     policy = aws_iam_policy.prometheus.arn
#   }

#   oidc_providers = {
#     one = {
#       provider_arn               = "arn:aws:iam::012345678901:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/5C54DDF35ER19312844C7333374CC09D"
#       namespace_service_accounts = ["default:my-app-staging", "canary:my-app-staging"]
#     }
#     two = {
#       provider_arn               = "arn:aws:iam::012345678901:oidc-provider/oidc.eks.ap-southeast-1.amazonaws.com/id/5C54DDF35ER54476848E7333374FF09G"
#       namespace_service_accounts = ["default:my-app-staging"]
#     }
#   }
# }


# resource "aws_iam_policy" "prometheus" {
#   name        = "prometheus_s3"
#   description = "prometheus s3 policy"


#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid = "AllowS3Operations"
#         Action = [
#           "s3:ListBucketMultipartUploads",
#           "s3:ListMultipartUploadParts",
#           "s3:ListBucket",
#           "s3:GetObject",
#           "s3:GetObjectTagging",
#           "s3:PutObjectTagging",
#           "s3:AbortMultipartUpload",
#           "s3:DeleteObject",
#           "s3:PutObject"
#         ]
#         Effect = "Allow"
#         Resource = [
#           "arn:aws:s3:::${bucket_name}/*",
#           "arn:aws:s3:::${bucket_name}"
#         ]
#       },
#     ]
#   })
# }