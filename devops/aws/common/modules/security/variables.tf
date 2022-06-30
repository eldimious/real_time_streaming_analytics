variable "vpc_id" {
  description = "The region to use for this module."
}

variable "create_vpc" {
  description = "The region to use for this module."
}

variable "create_sg" {
  description = "The region to use for this module."
}

variable "rule_ingress_description" {
  description = "The region to use for this module."
}

variable "rule_egress_description" {
  description = "The region to use for this module."
}

variable "ingress_cidr_blocks" {
  description = "The region to use for this module."
  default     = []
}

variable "ingress_from_port" {
  description = "The region to use for this module."
}

variable "ingress_to_port" {
  description = "The region to use for this module."
}

variable "ingress_protocol" {
  description = "The region to use for this module."
}

variable "ingress_source_security_group_id" {
  description = "The region to use for this module."
  default     = null
}

variable "egress_cidr_blocks" {
  description = "The region to use for this module."
  default     = []
}

variable "egress_from_port" {
  description = "The region to use for this module."
}

variable "egress_to_port" {
  description = "The region to use for this module."
}

variable "egress_protocol" {
  description = "The region to use for this module."
}

variable "egress_source_security_group_id" {
  description = "The region to use for this module."
  default     = null
}

variable "description" {
  description = "The region to use for this module."
}

variable "sg_name" {
  description = "The region to use for this module."
}

variable "security_group_id" {
  description = "ID of existing security group whose rules we will manage"
  type        = string
  default     = null
}
