terraform {
  cloud {
    organization = "ksw29555_personal_project"
    workspaces {
      name = "prod"
    }
  }

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}


provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#     command     = "aws"
#   }
# }

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

# added for argocd CRD workaround
# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1380
provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}

# ----------------------------------

module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  env          = var.env

  cidr               = var.vpc_cidr
  azs                = var.vpc_azs
  public_subnets     = var.vpc_public_subnets
  private_subnets    = var.vpc_private_subnets
  database_subnets   = var.vpc_database_subnets
  single_nat_gateway = var.vpc_single_nat_gateway
}

module "eks" {
  source = "../../modules/eks"

  project_name = var.project_name
  env          = var.env

  eks_cluster_version            = var.eks_cluster_version
  cluster_endpoint_public_access = var.eks_cluster_endpoint_public_access

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  vpc_owner_id    = module.vpc.vpc_owner_id

  # managed node group config
  desired_size   = var.eks_cluster_desired_size
  min_size       = var.eks_cluster_min_size
  max_size       = var.eks_cluster_max_size
  disk_size      = var.eks_cluster_disk_size
  label_role     = var.eks_cluster_label_role
  instance_types = var.eks_cluster_instance_types
  capacity_type  = var.eks_cluster_capacity_type


  # aws secrets manager
  db_password = module.db.db_password
  db_endpoint = module.db.db_endpoint
  acm_arn     =  module.route53.acm_arn

}

# route53 & acm
module "route53" {
  source       = "../../modules/route53"
  project_name = var.project_name
  env          = var.env
  domain_name  = var.domain_name
}


# db & secrets manager
module "db" {
  source       = "../../modules/db"
  project_name = var.project_name
  env          = var.env

  vpc_security_group_id = module.vpc.vpc_security_group_id
  subnet_ids            = module.vpc.db_subnet_ids

  engine            = var.db_engine
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  db_name           = var.db_name
  username          = var.db_username
}

