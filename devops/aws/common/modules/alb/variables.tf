variable "create_alb" {
  description = "Controls if the Load Balancer should be created"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "The VPC id"
}

variable "alb_name" {
  description = "The name of the loadbalancer"
}

variable "load_balancer_type" {
  description = "The type of load balancer to create. Possible values are application or network."
  type        = string
  default     = "application"
}

variable "subnet_ids" {
  type        = list(any)
  description = "List of subnets"
}

variable "internal" {
  description = "Boolean determining if the load balancer is internal or externally facing."
  type        = bool
  default     = false
}

variable "security_groups" {
  description = "The security groups to attach to the load balancer. e.g. [\"sg-edcd9784\",\"sg-edcd9785\"]"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Indicate the environment"
  default     = "dev"
}

variable "http_tcp_listeners" {
  description = "A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target_group_index (defaults to http_tcp_listeners[count.index])"
  type        = any
  default     = []
}
