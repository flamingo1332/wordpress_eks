variable "aws_access_key" {
  type        = string
  description = "AWS access key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
}




# domain
variable "domain_name" {
  description = "domain name"
  type        = string
  default     = "wordpress.ksw29555-cloudresume.name"
}




