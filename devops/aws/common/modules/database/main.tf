module "database" {
  source = "terraform-aws-modules/rds/aws"
  version = "~> 3.5"

  identifier = var.database_identifier

  engine                     = var.database_engine
  engine_version             = var.database_engine_version
  auto_minor_version_upgrade = var.database_auto_minor_version_upgrade
  family                     = var.database_family # DB parameter group
  major_engine_version       = var.database_engine_major_engine_version # DB option group
  instance_class             = var.database_instance_class

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = false

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  name     = var.database_name
  username = var.database_username
  password = var.database_password
  port     = var.database_port

  multi_az               = true
  subnet_ids             = var.subnet_ids
  vpc_security_group_ids = var.security_group_ids

  maintenance_window              = var.database_maintenance_window
  backup_window                   = var.database_backup_window
  enabled_cloudwatch_logs_exports = var.database_enabled_cloudwatch_logs_exports

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_role_name                  = var.monitoring_role_name
  monitoring_interval                   = 60

  parameters = concat([
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ], var.database_parameters)

  db_option_group_tags    = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
  db_subnet_group_tags    = {
    "Sensitive" = "high"
  }
}
