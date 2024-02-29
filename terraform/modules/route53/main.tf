data "aws_route53_zone" "selected" {
  name         = substr(var.domain_name, 10, length(var.domain_name))
  private_zone = false
}

# certificate
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = var.domain_name
  zone_id     = data.aws_route53_zone.selected.zone_id

  validation_method = "DNS"

  subject_alternative_names = ["www.${var.domain_name}"]

  wait_for_validation = true


  tags = {
    Project     = var.project_name
    Environment = var.env
  }
}


