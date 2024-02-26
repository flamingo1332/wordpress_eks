# RDS for wordpress DB
module "db" {
  source     = "terraform-aws-modules/rds/aws"
  version    = "~> 6.0"
  identifier = "wordpress-db-instance"

  vpc_security_group_ids = [var.vpc_security_group_id]
  db_subnet_group_name   = var.db_subnet_group_name
  subnet_ids             = var.db_subnet_ids

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  # minimum value for cost
  allocated_storage = 20

  db_name  = var.db_name
  username = var.db_master_username
  password = random_password.db_password.result
  port     = "3306"

  # t2.micro does not support encryption at rest
  storage_encrypted = false

  # iam authentication
  iam_database_authentication_enabled = true

  manage_master_user_password = false

  # for demonstration
  skip_final_snapshot = true

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"


  # prefix 관련 에러발생
  create_db_option_group    = false
  create_db_parameter_group = false

  # DB parameter group
  family = "mysql5.7"
  # DB option group
  major_engine_version = "5.7"


  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  tags = {
    Project     = var.project_name
    Environment = var.env
  }
}


resource "random_password" "db_password" {
  length           = 12
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}


# create a db user for aws iam authentication
resource "null_resource" "db_user" {
  depends_on = [module.db]

  provisioner "local-exec" {
    command = <<EOF
    mysql -h ${module.db.db_instance_address} -u ${var.db_master_username} -p'${random_password.db_password.result}' -D ${var.db_name} -e "CREATE USER '${var.db_username}' IDENTIFIED WITH AWSAuthenticationPlugin as 'RDS'; GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, INDEX, LOCK TABLES ON ${var.db_name}.* TO '${var.db_username}'; FLUSH PRIVILEGES;"
    EOF
  }
}