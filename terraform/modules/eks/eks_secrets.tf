# store secret in secrets_manager
# and argocd external secrets operator(or vault plugin) will pick it up
module "secrets_manager" {
  source = "terraform-aws-modules/secrets-manager/aws"

  recovery_window_in_days = 7

  # Policy
  create_policy       = true
  block_public_policy = true
  policy_statements = {
    read = {
      sid = "AllowAccountRead"
      principals = [{
        type        = "AWS"
        identifiers = ["arn:aws:iam::1234567890:root"]
      }]
      actions   = ["secretsmanager:GetSecretValue"]
      resources = ["*"]
    }
  }

  # Version
  create_random_password           = true
  random_password_length           = 64
  random_password_override_special = "!@#$%^&*()_+"

  tags = {
    Project = "${var.project_name}_${var.env}"
  }

}

resource "aws_secretsmanager_secret" "eks_secrets" {
  name        = "eks_secrets"
  description = "Secrets required for eks bootstrap"
}


resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.eks_secrets.id
  secret_string = jsonencode({
    db_password = var.db_password,
    db_endpoint = var.db_endpoint,
    api_key           = "your_api_key"
    # Add other secrets as needed
  })
}

# 필요 리스트
# db password