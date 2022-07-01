################################################################################
# General AWS Configuration
################################################################################
variable "aws_profile" {
  description = "The AWS profile name"
  default     = "default"
}

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "eu-west-2"
}

################################################################################
# Network Configuration
################################################################################
variable "vpc_name" {
  description = "The name of the VPC. Other names will result from this."
  default     = "collector-vpc"
}

variable "create_vpc" {
  description = "Flag to define if we have to create vpc"
  type        = bool
  default     = true
}

variable "create_igw" {
  description = "Flag to define if we have to create IG"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Flag to define if we need only one NAT GW"
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "Flag to define enable NAT GW"
  type        = bool
  default     = true
}

variable "cidr_block" {
  description = "Network IP range"
  default     = "192.168.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones you want. Example: eu-west-2a and eu-west-2b"
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "public_subnet_cidrs" {
  description = "List of public cidrs, for every availability zone you want you need one. Example: 10.0.0.0/24 and 10.0.1.0/24"
  default     = ["192.168.0.0/19", "192.168.32.0/19"]
}

variable "private_subnet_cidrs" {
  description = "List of private cidrs, for every availability zone you want you need one. Example: 10.0.0.0/24 and 10.0.1.0/24"
  default     = ["192.168.128.0/19", "192.168.160.0/19"]
}

variable "enable_dns_support" {
  description = "DNS support"
  default     = true
}

variable "enable_dns_hostnames" {
  description = "DNS hostnames"
  default     = true
}

################################################################################
# ALB
################################################################################
variable "create_alb" {
  description = "Flag to define if we have to create ALB"
  type        = bool
  default     = true
}

################################################################################
# Project metadata
################################################################################
variable "project" {
  description = "Project name"
  default     = "collector_ecs_fargate"
}

variable "environment" {
  description = "Indicate the environment"
  default     = "dev"
}

################################################################################
# ECS Configuration
################################################################################
variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "ecsTaskExecutionRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "512"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "1024"
}

variable "health_check_grace_period_seconds" {
  description = ""
  default     = 180
}

variable "network_mode" {
  description = "Set network mode of esc tasks"
  default     = "awsvpc"
}

################################################################################
# API collector Service Configuration
################################################################################
variable "collector_api_tg" {
  description = "Defines service tg"
  default     = "collector-api-tg"
}

variable "collector_api_tg_paths" {
  default = ["/collector", "/collector/*"]
}

variable "collector_api_name" {
  description = "Defines service name"
  default     = "collector_api"
}

variable "collector_api_image" {
  description = "Defines service image"
  default     = "eldimious/collector:latest"
}

variable "collector_api_aws_logs_group" {
  description = "Defines logs group"
  default     = "/ecs/collector_api"
}

variable "collector_api_task_family" {
  description = "Defines logs group"
  default     = "collector_api_task"
}

variable "collector_api_port" {
  description = "Port exposed by the collector image"
  default     = 3000
}

variable "collector_api_desired_count" {
  description = "Number of collector docker containers to run"
  default     = 1
}

variable "collector_api_max_count" {
  description = "Max number of collector docker containers to run"
  default     = 6
}

variable "collector_api_health_check_path" {
  default = "/collector/health-check"
}

variable "collector_api_network_mode" {
  default = "awsvpc"
}

variable "collector_api_task_compatibilities" {
  default = ["FARGATE"]
}

variable "collector_api_launch_type" {
  default = "FARGATE"
}

################################################################################
# ALB Configuration
################################################################################
variable "internal_elb" {
  description = "Make ALB private? (Compute nodes are always private under ALB)"
  default     = false
}

################################################################################
# Discovery Service Configuration
################################################################################
variable "discovery_ttl" {
  description = "Time to live"
  default     = 10
}

variable "discovery_routing_policy" {
  description = "Defines routing policy"
  default     = "MULTIVALUE"
}

################################################################################
# Database Configuration
################################################################################
# collector DB
variable "collector_database_username" {
  description = "The username for the collector DB master"
  type        = string
  sensitive   = true
}

variable "collector_database_password" {
  description = "The password for the collector DB master"
  type        = string
  sensitive   = true
}

variable "collector_database_identifier" {
  description = "collector DB name"
  type        = string
}

variable "collector_monitoring_role_name" {
  description = "collector monitoring role name"
  type        = string
  default     = "collectorDatabaseMonitoringRole"
}

variable "kinesis_stream_name" {
  description = "kinesis stream name for transactions"
  type        = string
  default     = "transactions_stream"
}

variable "kinesis_firehose_delivery_stream_name" {
  description = "kinesis firehose delivery stream name for transactions"
  type        = string
  default     = "transactions_s3_delivery_stream"
}