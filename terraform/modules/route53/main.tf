data "aws_route53_zone" "selected" {
  name         = "ksw29555-cloudresume.name"
  private_zone = false
}

# certificate
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = var.domain_name
  zone_id     = data.aws_route53_zone.selected.zone_id

  validation_method    = "DNS"

  subject_alternative_names = ["www.${var.domain_name}"]

  wait_for_validation  = true

  tags = {
    Project = "${var.project_name}_${var.env}"
  }
}


# 
# let aws-lb-controller handle route53 records
# 
# record for subdomain wordpress.ksw29555-cloudresume.name
# module "dns_records" {
#   source  = "terraform-aws-modules/route53/aws//modules/records"
#   version = "~> 2.0" # Specify the module version

#   zone_id = data.aws_route53_zone.selected.zone_id # Replace with the Zone ID of ksw29555-cloudresume.name
#   records = [
#     {
#       name = "wordpress.ksw29555-clourdresume.name"
#       type = "A"
#       alias = {
#         name                   = module.alb.alb_dns_name
#         zone_id                = module.alb.alb_zone_id
#         evaluate_target_health = true
#       }
#     }
#   ]
# }



