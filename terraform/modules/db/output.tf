
output "db_endpoint" {
  description = "db_endpoint"
  value       = module.db.db_instance_endpoint
}

output "db_instance_resource_id" {
  description = "db_id"
  value       = module.db.db_instance_resource_id
}

output "db_instance_username" {
  description = "db_username"
  value       = module.db.db_instance_username
}

output "db_password" {
  description = "db_password"
  value       = random_password.db_password.result
  sensitive   = true
}


