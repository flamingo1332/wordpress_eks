output "db_endpoint" {
  description = "db_endpoint"
  value       = module.db.db_instance_endpoint
}
output "db_password" {
  description = "db_password"
  value       = random_password.db_password.result
  sensitive   = true
}
