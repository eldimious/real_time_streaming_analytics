# region
variable "region" {
  description = "The region to use for this module."
  default     = "eu-west-2"
}

################################################################################
# Project metadata
################################################################################
variable "project" {
  description = "Project name"
  default     = "ecs_fargate_ms"
}

variable "environment" {
  description = "Indicate the environment"
  default     = "dev"
}

# vpc
variable "create_vpc" {
  description = "Define if we have to create new VPC"
  default     = true
}

variable "vpc_name" {
  description = "The name of the VPC. Other names will result from this."
  default     = "ms-vpc"
}

variable "create_igw" {
  description = "Define if we have to create IG"
  default     = true
}

variable "single_nat_gateway" {
  description = "Define we need single NAT GW"
  default     = false
}

variable "enable_nat_gateway" {
  description = "Define we need enable NAT GW"
  default     = true
}

variable "cidr_block" {
  default     = "10.0.0.0/24"
  description = "Network within which the Subnets will be created."
}

# network resources
variable "enable_dns_support" {
  default     = true
  description = " (Optional) A boolean flag to enable/disable DNS support in the VPC"
}

variable "enable_dns_hostnames" {
  default     = true
  description = " (Optional) A boolean flag to enable/disable DNS hostnames in the VPC"
}

variable "private_subnet_cidrs" {
  type        = list(any)
  description = "List of private cidrs, for every availability zone you want you need one. Example: 10.0.0.0/24 and 10.0.1.0/24"
}

variable "public_subnet_cidrs" {
  type        = list(any)
  description = "List of public cidrs, for every availability zone you want you need one. Example: 10.0.0.0/24 and 10.0.1.0/24"
}

variable "availability_zones" {
  type        = list(any)
  description = "List of availability zones you want. Example: eu-west-1a and eu-west-1b"
}

variable "public_subnet_additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

variable "private_subnet_additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}
