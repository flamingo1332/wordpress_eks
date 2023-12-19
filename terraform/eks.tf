
# eks cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 19.0"

  cluster_name    = "wordpress-cluster"
  cluster_version = "1.28"
  
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  enable_irsa = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

# addon (kube-proxy, vpc-cni, coredns)
  cluster_addons = {
    kube-proxy = {
      most_recent = true
    }

    vpc-cni = {
      most_recent = true
    }

    coredns = {
      most_recent = true
      configuration_values = jsonencode({
        replicaCount = 2
        resources = {
          limits = {
            cpu    = "100m"
            memory = "150Mi"  
          }
          requests = {
            cpu    = "100m"
            memory = "150Mi"
          }
        }
      })
    }
  }
  
# nodes
  eks_managed_node_groups = {
    general = {
      desired_size = 1
      min_size     = 1
      max_size     = 5
      disk_size    = 10

      labels = {
        role = "general"
      }

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }
  }

  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = module.eks_admins_iam_role.iam_role_arn
      username = module.eks_admins_iam_role.iam_role_name
      groups   = ["system:masters"]
    },
  ]


  tags = {
    Environment = "prod"
  }
}





# output "cluster_certificate_authority_data" {
#   value = module.eks.cluster_certificate_authority_data
# }

# output "cluster_endpoint" {
#   value = module.eks.cluster_endpoint
# }

# output "cluster_name" {
#   value = module.eks.cluster_name
# }




