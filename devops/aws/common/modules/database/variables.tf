variable "database_identifier" {
  description = "Database identifier"
}

variable "database_name" {
  description = "Database name"
  type        = string
  sensitive   = true
  default     = "postgres"
}

variable "database_username" {
  description = "The password for the DB master"
  type        = string
  sensitive   = true
}

variable "database_password" {
  description = "The password for the DB master"
  type        = string
  sensitive   = true
}

variable "database_port" {
  description = "DB port"
  type        = number
  default = 5432
}

variable "subnet_ids" {
  description = "The ids of the subnets for the DB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group ids for the DB"
  type        = list(string)
}

variable "monitoring_role_name" {
  description = "Monitoring role name of the DB"
  type        = string
}

variable "database_engine" {
  description = "DB engine"
  type        = string
  default     = "postgres"
}

variable "database_engine_version" {
  description = "DB engine version"
  type        = string
  default     = "11.12"
}

variable "database_auto_minor_version_upgrade" {
  description = "DB auto minor version upgrade"
  type        = bool
  default     = false
}

variable "database_family" {
  description = "DB family"
  type        = string
  default     = "postgres11"
}

variable "database_engine_major_engine_version" {
  description = "DB engine major version"
  type        = string
  default     = "11"
}

variable "database_instance_class" {
  description = "DB instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "database_maintenance_window" {
  description = "DB maintenance window"
  type        = string
  default     = "Mon:00:00-Mon:03:00"
}

variable "database_backup_window" {
  description = "DB backup window"
  type        = string
  default     = "03:00-06:00"
}

variable "database_enabled_cloudwatch_logs_exports" {
  description = "DB enabled cloudwatch logs exports"
  type        = list(string)
  default     = ["postgresql", "upgrade"]
}

variable "database_parameters" {
  description = "DB parameters"
  type        = list(map(string))
  default     = []
}
