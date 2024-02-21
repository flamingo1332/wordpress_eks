output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "private subnets of the VPC"
  value       = module.vpc.private_subnets
}

output "vpc_owner_id" {
  description = "vpc_owner_id"
  value       = module.vpc.vpc_owner_id
}

output "vpc_security_group_id" {
  description = "vpc_security_group_id"
  value       = module.vpc.default_security_group_id
}


output "db_subnet_ids" {
  description = "db_subnet_ids"
  value       = module.vpc.database_subnets
}

output "db_subnet_group_name" {
  description = "database_subnet_group_name"
  value       = module.vpc.database_subnet_group_name
}