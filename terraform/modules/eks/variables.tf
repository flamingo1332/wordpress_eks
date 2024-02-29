variable "env" {
  description = "environment"
  type        = string
}
variable "project_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "aws_region" {
  description = "aws region"
  type        = string
}

variable "domain_name" {
  description = "domain name"
  type        = string
}

variable "slack_url" {
  description = "slack notification url"
  type        = string
}

# eks cluster

variable "eks_cluster_version" {
  description = "eks cluster version"
  type        = string
}

variable "eks_cluster_endpoint_public_access" {
  description = "cluster_endpoint_public_access"
  type        = bool
}

variable "secrets_manager_name" {
  type = string
}

# vpc 

variable "vpc_id" {
  description = "vpc id"
  type        = string
}

variable "vpc_private_subnets" {
  description = "vpc private subnets"
  type        = list(string)
}

variable "vpc_owner_id" {
  description = "vpc_owner_id"
  type        = string
}


# eks managed node

variable "eks_cluster_desired_size" {
  description = "desired cluster size"
  type        = number
}
variable "eks_cluster_min_size" {
  description = "cluster min size"
  type        = number
}
variable "eks_cluster_max_size" {
  description = "cluster max size"
  type        = number
}
variable "eks_cluster_disk_size" {
  description = "cluster disk size"
  type        = number
}

variable "eks_cluster_label_role" {
  description = "label role"
  type        = string
}

variable "eks_cluster_instance_types" {
  description = "instance_types"
  type        = list(string)
}

variable "eks_cluster_capacity_type" {
  description = "instance capacity type"
  type        = string
}


# db
variable "db_name" {
  description = "db_name"
  type        = string
}
variable "db_username" {
  description = "db_user"
  type        = string
}

variable "db_password" {
  description = "db_password"
  type        = string
  sensitive   = true
}

variable "db_endpoint" {
  description = "db_endpoint"
  type        = string
  sensitive   = true
}

variable "db_instance_resource_id" {
  description = "db_instance_resource_id"
  type        = string
}

variable "db_instance_username" {
  description = "db_instance_username"
  type        = string
}


# acm
variable "acm_arn" {
  description = "acm_arn"
  type        = string
}

variable "hosted_zone_arn" {
  description = "hosted zone arn"
  type        = string
}