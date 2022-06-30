variable "project" {
  description = "ECS Cluster name"
  type        = string
}

variable "create_capacity_provider" {
  description = "Controls if need to create capacity provider"
  type        = bool

}

variable "capacity_provider_name" {
  description = "Name of capacity provider"
  type        = string
  default     = null
}

variable "aws_autoscaling_group_arn" {
  description = "Name of capacity provider"
  type        = string
  default     = null
}
