output "cluster_endpoint" {
  description = "cluster_endpoint"
  value       = module.eks.cluster_endpoint
}
output "cluster_certificate_authority_data" {
  description = "cluster_certificate_authority_data"
  value       = module.eks.cluster_certificate_authority_data
}
output "cluster_name" {
  description = "cluster_name"
  value       = module.eks.cluster_name
}
output "test" {
  description = "test"
  value       = module.aws_load_balancer_controller_irsa_role.iam_role_arn
}

