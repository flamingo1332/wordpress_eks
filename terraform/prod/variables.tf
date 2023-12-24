variable "project_name" {
  type        = string
  description = "AWS access key"
  default     = "wordpress_eks"
}


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
  default     = "ap-northeast-1"
}



# domain
variable "domain_name" {
  description = "domain name"
  type        = string
  default     = "wordpress.ksw29555-cloudresume.name"
}




