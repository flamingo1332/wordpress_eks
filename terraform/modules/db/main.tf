# RDS free tier instance for wordpress DB
module "db" {
  source     = "terraform-aws-modules/rds/aws"
  version    = "~> 6.0"
  identifier = "wordpress-db-instance"

  vpc_security_group_ids = var.vpc_security_group_id
  subnet_ids             = var.subnet_ids

  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = 20

  db_name  = var.db_name
  username = var.username
  password = random_password.db_password.result
  port     = "3306"



  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"



  # prefix 관련 에러발생
  create_db_option_group    = true
  create_db_parameter_group = true

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
    Project = "${var.project_name}_${var.env}"
  }
}


resource "random_password" "db_password" {
  length           = 12
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

