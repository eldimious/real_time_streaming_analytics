output "db_address" {
  description = "The address of the RDS instance"
  value       = module.database.db_instance_address
}

output "db_arn" {
  description = "The ARN of the RDS instance"
  value       = module.database.db_instance_arn
}


output "db_endpoint" {
  description = "The connection endpoint"
  value       = module.database.db_instance_endpoint
}

output "db_instance_name" {
  description = "The database name"
  value       = module.database.db_instance_name
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.database.db_instance_address
}

output "db_instance_port" {
  description = "The database port"
  value       = module.database.db_instance_port
}

output "db_master_password" {
  description = "The master password"
  value       = module.database.db_master_password
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = module.database.db_instance_username
}
