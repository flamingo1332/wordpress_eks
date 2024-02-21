# https://docs.aws.amazon.com/eks/latest/userguide/creating-a-vpc.html
# vpc
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}_vpc"
  cidr = var.cidr

  azs              = var.azs
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

  create_igw         = true
  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway

  create_database_subnet_group = true

  enable_dns_hostnames = true
  enable_dns_support   = true



  # for aws-lb-controller
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }


  tags = {
    Project     = var.project_name
    Environment = var.env
  }
}
