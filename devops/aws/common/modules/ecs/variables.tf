# region
variable "aws_region" {
  description = "The region to use for this module."
}

variable "vpc_id" {
  description = "The VPC id"
  type        = string
}

################################################################################
# Project metadata
################################################################################
variable "cluster_id" {
  description = "The ECS cluster ID where the service should run"
  type        = string
}

variable "cluster_name" {
  description = "The ECS cluster name where the service should run"
  type        = string
}

variable "has_discovery" {
  description = "Flag to switch on service discovery. If true, a valid DNS namespace must be provided"
  type        = bool
  default     = true
}

variable "dns_namespace_id" {
  description = "The Route53 DNS namespace ID where the ECS task is registered"
  type        = string
}

variable "discovery_ttl" {
  description = "Time to live"
  default     = 10
}

variable "discovery_routing_policy" {
  description = "Defines routing policy"
  default     = "MULTIVALUE"
}

variable "task_compatibilities" {
  type        = list(any)
  description = "Defines ecs task compatibility"
}

################################################################################
# ECS Configuration
################################################################################
variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown. Only valid for services configured to use load balancers."
  default     = 180
}

################################################################################
# API Books Service Configuration
################################################################################
variable "logs_retention_in_days" {
  description = "Defines service logs retention period"
}

variable "service_name" {
  description = "The task name which gives the name to the ECS task, container and service discovery name"
  type        = string
}

variable "service_image" {
  description = "The Docker image to run with the task"
  type        = string
}

variable "service_aws_logs_group" {
  description = "Defines logs group"
}

variable "service_port" {
  description = "Port exposed by the docker image"
}

variable "service_desired_count" {
  description = "Number of books docker containers to run"
}

variable "service_max_count" {
  description = "Max number of books docker containers to run"
}

variable "service_task_family" {
  description = "Defines logs group"
}

variable "service_enviroment_variables" {
  description = "Defines service enviroment variables"
}

variable "service_secrets_variables" {
  description = "Defines service secret variables"
  default     = []
}

variable "service_health_check_path" {
  description = "Path for health check"
  type        = string
}

variable "network_mode" {
  description = "Defines ecs task network mode"
}

variable "launch_type" {
  description = "Defines ecs task network mode"
}

variable "service_security_groups_ids" {
  description = "IDs of SG on a ecs task network"
}

variable "subnet_ids" {
  description = "The VPC subnets IDs where the application should run"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Define we attach public ip to task"
}

variable "iam_role_ecs_task_execution_role" {
  description = "ARN of the IAM role that allows Amazon ECS to make calls to your load balancer on your behalf."
}

variable "iam_role_policy_ecs_task_execution_role" {
  description = "Policy of the IAM role that allows Amazon ECS to make calls to your load balancer on your behalf."
}

variable "alb_listener" {
  description = "Defines ALB listener where service is registered"
}

variable "has_alb" {
  description = "Whether the service should be registered to an application load balancer"
  type        = bool
}

variable "alb_listener_tg" {
  description = "Name of ALB listener target group"
  type        = string
}

variable "alb_listener_port" {
  description = "Port of ALB listener target group"
  type        = string
}

variable "alb_listener_protocol" {
  description = "Protocol of ALB listener target group"
  type        = string
}

variable "alb_listener_target_type" {
  description = "Protocol of ALB listener target group"
  type        = string
}

variable "alb_listener_arn" {
  description = "ARN of ALB listener"
  type        = string
}

variable "alb_listener_rule_priority" {
  description = "Priority number of ALB listener rule"
}

variable "alb_listener_rule_type" {
  description = "Type of ALB listener rule"
  type        = string
}

variable "alb_service_tg_paths" {
  description = "Paths which are used from ALB listener rule to route the request"
  type        = list(string)
}

variable "enable_autoscaling" {
  description = "Flag to define if we need auto scaling."
  type        = bool
}

variable "autoscaling_settings" {
  type = map(any)
  # default = {
  #   max_capacity       = 1
  #   min_capacity       = 1
  #   target_cpu_value   = 60
  #   scale_in_cooldown  = 300
  #   scale_out_cooldown = 300
  # }
  description = "Settings of Auto Scaling."
}

variable "autoscaling_name" {
  description = "Name of autoscaling group."
  type        = string
}

variable "has_ordered_placement" {
  description = "Flag to define if ordered placement strategy should be set."
  type        = bool
  default     = false
}
