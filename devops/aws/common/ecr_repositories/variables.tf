################################################################################
# General AWS Configuration
################################################################################
variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "eu-west-2"
}

variable "aws_profile" {
  description = "The AWS profile name"
  default     = "default"
}

variable "default_tags" {
  description = "Default tags to set to every resource"
  type        = map(string)
  default     = {
    Project   = "analytics-collector"
    ManagedBy = "terraform"
  }
}

variable "repositories" {
  description = "Defines the repositories to create"
  type        = set(string)
  default     = [
    "analytics-collector-api"
  ]
}