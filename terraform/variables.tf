variable "aws_access_key" {
  type        = string
  description = "AWS access key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
}

variable "aws_region" {
  type        = string
  description = "AWS default region"
  default     = "ap-northeast-1"
}

variable "domain_name" {
  description = "domain name"
  type = string
  default = "ksw29555-cloudresume.name"
}


