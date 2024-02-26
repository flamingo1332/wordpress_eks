variable "aws_access_key" {
  type        = string
  description = "AWS access key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
}


variable "aws_region" {
  description = "region"
  type        = string
}

variable "env" {
  description = "environtment"
  type        = string
}

variable "project_name" {
  type        = string
  description = "AWS access key"
}

variable "domain_name" {
  description = "domain name"
  type        = string
}

variable "slack_url" {
  description = "slack_url for notification(eks monitoring)"
  type        = string
}


# --------------------------------------------------------
# vpc
# --------------------------------------------------------
variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overriden"
  type        = string
}

variable "vpc_azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
}

variable "vpc_public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
}

variable "vpc_private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
}
variable "vpc_database_subnets" {
  description = "A list of db subnets inside the VPC"
  type        = list(string)
}

variable "vpc_single_nat_gateway" {
  description = "single nat gateway in vpc"
  type        = bool
}



# --------------------------------------------------------
# eks
# --------------------------------------------------------

variable "eks_cluster_version" {
  description = "eks_cluster_version"
  type        = string
}
variable "eks_cluster_endpoint_public_access" {
  description = "eks_cluster_version"
  type        = bool
}

variable "eks_cluster_desired_size" {
  description = "eks managed node desired_size"
  type        = number
}
variable "eks_cluster_min_size" {
  description = "eks managed node min_size"
  type        = number
}
variable "eks_cluster_max_size" {
  description = "eks managed node max_size"
  type        = number
}
variable "eks_cluster_disk_size" {
  description = "eks managed node disk_size"
  type        = number
}

variable "eks_cluster_label_role" {
  description = "eks managed node label_role"
  type        = string
}

variable "eks_cluster_instance_types" {
  description = "eks managed node instance_types"
  type        = list(string)
}


variable "eks_cluster_capacity_type" {
  description = "eks managed node instance capacity type"
  type        = string
}


variable "secrets_manager_name" {
  type = string
}


# --------------------------------------------------------
# db
# --------------------------------------------------------


variable "db_engine" {
  description = "rds engine"
  type        = string
}

variable "db_engine_version" {
  description = "rds engine version"
  type        = string
}

variable "db_instance_class" {
  description = "instance class"
  type        = string
}

variable "db_allocated_storage" {
  description = "allocated storage"
  type        = number
}

variable "db_name" {
  description = "db_name"
  type        = string
}

variable "db_username" {
  description = "db_username"
  type        = string
}

variable "db_master_username" {
  description = "db_master_username"
  type        = string
}
