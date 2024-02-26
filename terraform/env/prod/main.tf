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
  aws_region   = var.aws_region
  domain_name  = var.domain_name

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
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = module.db.db_password
  db_endpoint          = module.db.db_endpoint
  acm_arn              = module.route53.acm_arn
  slack_url            = var.slack_url
  secrets_manager_name = var.secrets_manager_name

  #  irsa role
  hosted_zone_arn         = module.route53.hosted_zone_arn
  db_instance_resource_id = module.db.db_instance_resource_id
  db_instance_username    = module.db.db_instance_username
}


# route53 & acm
module "route53" {
  source       = "../../modules/route53"
  project_name = var.project_name
  env          = var.env
  domain_name  = var.domain_name
}


# rds for wordpress
module "db" {
  source       = "../../modules/db"
  project_name = var.project_name
  env          = var.env

  vpc_security_group_id = module.vpc.vpc_security_group_id
  db_subnet_ids         = module.vpc.db_subnet_ids
  db_subnet_group_name  = module.vpc.db_subnet_group_name

  engine            = var.db_engine
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  db_name           = var.db_name
  db_username       = var.db_username
  db_master_username= var.db_master_username
}

