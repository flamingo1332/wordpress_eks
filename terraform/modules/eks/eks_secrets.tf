# store secret in secrets_manager
# for argocd vault plugin to pick up
resource "aws_secretsmanager_secret" "eks_secrets" {
  name                    = var.secrets_manager_name
  description             = "Secrets required for eks bootstrap"
  recovery_window_in_days = 0
  tags = {
    Project     = var.project_name
    Environment = var.env
  }
}

resource "aws_secretsmanager_secret_version" "eks_secrets" {
  secret_id = aws_secretsmanager_secret.eks_secrets.id
  secret_string = jsonencode({
    aws_region   = var.aws_region,
    domain_name  = var.domain_name,
    env          = var.env,
    slack_url    = var.slack_url
    project_name = var.project_name

    cluster_name = module.eks.cluster_name,
    vpc_id       = var.vpc_id,

    db_name                 = var.db_name,
    db_username             = var.db_username,
    db_password             = var.db_password,
    db_endpoint             = substr(var.db_endpoint, 0, length(var.db_endpoint) - 5),
    wordpress_user_password = random_password.wordpress_user_password.result,
    acm_arn                 = var.acm_arn,

    arn_aws_load_balancer_controller_irsa_role = module.aws_load_balancer_controller_irsa_role.iam_role_arn,
    arn_external_dns_irsa_role                 = module.external_dns_irsa_role.iam_role_arn,
    arn_cluster_autoscaler_irsa_role           = module.cluster_autoscaler_irsa_role.iam_role_arn,

  })
}


resource "random_password" "wordpress_user_password" {
  length  = 12
  special = false
}

