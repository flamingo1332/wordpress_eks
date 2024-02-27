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

  vpc_cidr               = var.vpc_cidr
  vpc_azs                = var.vpc_azs
  vpc_public_subnets     = var.vpc_public_subnets
  vpc_private_subnets    = var.vpc_private_subnets
  vpc_database_subnets   = var.vpc_database_subnets
  vpc_single_nat_gateway = var.vpc_single_nat_gateway
}

module "eks" {
  source = "../../modules/eks"

  project_name = var.project_name
  env          = var.env
  aws_region   = var.aws_region
  domain_name  = var.domain_name

  eks_cluster_version            = var.eks_cluster_version
  cluster_endpoint_public_access = var.eks_cluster_endpoint_public_access

  vpc_id              = module.vpc.vpc_id
  vpc_private_subnets = module.vpc.vpc_private_subnets
  vpc_owner_id        = module.vpc.vpc_owner_id

  # managed node group config
  eks_cluster_desired_size   = var.eks_cluster_desired_size
  eks_cluster_min_size       = var.eks_cluster_min_size
  eks_cluster_max_size       = var.eks_cluster_max_size
  eks_cluster_disk_size      = var.eks_cluster_disk_size
  eks_cluster_label_role     = var.eks_cluster_label_role
  eks_cluster_instance_types = var.eks_cluster_instance_types
  eks_cluster_capacity_type  = var.eks_cluster_capacity_type


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

  db_security_group_id = module.vpc.db_security_group_id
  db_subnet_ids         = module.vpc.db_subnet_ids
  db_subnet_group_name  = module.vpc.db_subnet_group_name

  db_engine            = var.db_engine
  db_engine_version    = var.db_engine_version
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_name              = var.db_name
  db_username          = var.db_username
  db_master_username   = var.db_master_username
}

