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
  type        = list(string)
}

variable "subnet_ids" {
  description = "subnet_ids"
  type        = list(string)
}


variable "engine" {
  description = "rds engine"
  type        = string
}

variable "engine_version" {
  description = "rds engine version"
  type        = string
}

variable "instance_class" {
  description = "instance class"
  type        = string
}

variable "allocated_storage" {
  description = "allocated storage"
  type        = number
}

variable "db_name" {
  description = "db_name"
  type        = string
}

variable "username" {
  description = "db_username"
  type        = string
}