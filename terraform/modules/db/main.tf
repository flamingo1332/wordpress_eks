# RDS for wordpress DB
module "db" {
  source     = "terraform-aws-modules/rds/aws"
  version    = "~> 6.0"
  identifier = "wordpress-db-instance"

  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = var.db_subnet_group_name
  subnet_ids             = var.db_subnet_ids

  engine            = var.db_engine
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage


  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result
  port     = "3306"

  # t2.micro does not support encryption at rest
  storage_encrypted = false

  # iam authentication
  iam_database_authentication_enabled = false

  manage_master_user_password = false

  # for demonstration
  skip_final_snapshot = true

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"


  # prefix 관련 에러발생
  create_db_option_group    = false
  create_db_parameter_group = false

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

# db password generation
resource "random_password" "db_password" {
  length           = 12
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# db security group
resource "aws_security_group" "db" {
  name        = "db"
  description = "allow connection to db from eks wordpress pod"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }
  tags = {
    Project     = var.project_name
    Environment = var.env
  }
}


# create a db user for aws iam authentication
# resource "null_resource" "db_user" {
#   depends_on = [module.db]

#   provisioner "local-exec" {
#     command = <<EOF
#     /usr/bin/mysql -h ${module.db.db_instance_address} -u ${var.db_master_username} -p'${random_password.db_password.result}' -D ${var.db_name} -e "CREATE USER '${var.db_username}' IDENTIFIED WITH AWSAuthenticationPlugin as 'RDS'; GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, INDEX, LOCK TABLES ON ${var.db_name}.* TO '${var.db_username}'; FLUSH PRIVILEGES;"
#     EOF
#   }
# }


