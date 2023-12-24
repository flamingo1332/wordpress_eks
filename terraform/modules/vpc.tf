# https://docs.aws.amazon.com/eks/latest/userguide/creating-a-vpc.html
# vpc
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "wordpress_vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-1a", "ap-northeast-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  create_igw = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true


  # aws lb controller 호환용
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }


  tags = {
    Environment = "prod"
  }
}


# output "vpc_id" {
#   value = module.vpc.vpc_id
# }

# output "subnet_ids" {
#   value = module.vpc.subnet_ids
# }
