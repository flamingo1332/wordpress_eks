variable "env" {
  description = "environment"
  type        = string
}
variable "project_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}


variable "eks_cluster_version" {
  description = "eks cluster version"
  type        = string
}

variable "cluster_endpoint_public_access" {
  description = "cluster_endpoint_public_access"
  type    = bool
}


# vpc 

variable "vpc_id" {
  description = "vpc id"
  type        = string
}

variable "private_subnets" {
  description = "vpc private subnets"
  type        = list(string)
}

variable "vpc_owner_id" {
  description = "vpc_owner_id"
  type        = string
}


# eks managed node

variable "desired_size" {
  description = "desired cluster size"
  type        = number
}
variable "min_size" {
  description = "cluster min size"
  type        = number
}
variable "max_size" {
  description = "cluster max size"
  type        = number
}
variable "disk_size" {
  description = "cluster disk size"
  type        = number
}

variable "label_role" {
  description = "label role"
  type        = string
}

variable "instance_types" {
  description = "instance_types"
  type        = list(string)
}

variable "capacity_type" {
  description = "instance capacity type"
  type        = string
}


# aws secrets manager
variable "db_password" {
  description = "db_password"
  type        = string
  sensitive =  true
}

variable "db_endpoint" {
  description = "db_endpoint"
  type        = string
}

variable "acm_arn" {
  description = "acm_arn"
  type        = string
}