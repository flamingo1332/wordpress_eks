terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.1.0"
    }
  }

  backend "s3" {
    bucket         = "ksw29555-terraform-backend"
    key            = "terraform/main.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "cloud_resume_terraform_lock"
  }
}


provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "aws" {
  alias      = "domain_source_account"
  region     = "us-east-1"
  access_key = var.aws_access_key_source
  secret_key = var.aws_secret_key_source
}


# vpc
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0" # You can update this to the version you need

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

# eks clusters
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.23.0" # You can update this to the version you need
  cluster_name    = "my-cluster"
  cluster_version = "1.21"
  subnets         = module.vpc.private_subnets

  node_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      instance_type = "m5.large"
      key_name      = var.key_name

      subnets = module.vpc.private_subnets
    }
  }
}

# create hosted zone in target account 
module "zones" {
  provider = "domain_source_account"
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.10.2"

  zones = {
    "wordpress.ksw29555-cloudresume.name" = {
      comment = "Hosted zone for wordpress.ksw29555-cloudresume.name"
      tags = {
        env = "production"
      }
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }

  providers = {
    aws = aws.domain_source_account
  }
}

# create nameserver in source account that points to nameservers on target account
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.10.2"

  zone_name = keys(module.zones.route53_zone_zone_id)[0]

  # Retrieve the nameservers from the zones module and create NS records for them
  records = [
    {
      name    = "wordpress.ksw29555-cloudresume.name"
      type    = "NS"
      ttl     = "300"
      records = module.zones.route53_zone_name_servers["wordpress.ksw29555-cloudresume.name"]
    }
  ]

  depends_on = [module.zones]
}



# module "acm" {
#   source = "./modules/acm"
#   providers = {
#     aws = aws.use1
#   }
#   domain_name = var.domain_name
# }

# # s3 bucket regional domain name
# # acm certificate arn
# module "cloudfront" {
#   source = "./modules/cloudfront"

#   domain_name = var.domain_name
#   s3_bucket_frontend_regional_domain_name = module.s3.s3_bucket_frontend_regional_domain_name
#   s3_bucket_frontend_id = module.s3.s3_bucket_frontend_id
#   acm_certificate_arn = module.acm.acm_certificate_arn
# }








