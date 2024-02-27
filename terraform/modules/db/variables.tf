variable "env" {
  description = "environment"
  type        = string
}
variable "project_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}




variable "vpc_security_group_id" {
  description = "vpc_security_group_id"
  type        = string
}

variable "db_subnet_ids" {
  description = "subnet_ids"
  type        = list(string)
}
variable "db_subnet_group_name" {
  description = "database_subnet_group_name"
  type        = string
}

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

variable "db_master_username" {
  description = "db_master_username"
  type        = string
}
variable "db_username" {
  description = "db_username"
  type        = string
}