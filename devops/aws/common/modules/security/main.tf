locals {
  this_sg_id = var.create_sg && var.create_sg ? concat(aws_security_group.this.*.id, [""])[0] : var.security_group_id
}

##########################
# Security Group
##########################
resource "aws_security_group" "this" {
  count = var.create_vpc && var.create_sg ? 1 : 0

  name        = var.sg_name
  description = var.description
  vpc_id      = var.vpc_id
}

#####################################
# Security Group Ingress Rules
#####################################
resource "aws_security_group_rule" "ingress_rules" {
  security_group_id = local.this_sg_id
  type              = "ingress"

  cidr_blocks = var.ingress_cidr_blocks
  description = var.rule_ingress_description

  from_port                = var.ingress_from_port
  to_port                  = var.ingress_to_port
  protocol                 = var.ingress_protocol
  source_security_group_id = var.ingress_source_security_group_id
}

#####################################
# Security Group Egress Rules
#####################################
resource "aws_security_group_rule" "egress_rules" {
  security_group_id = local.this_sg_id
  type              = "egress"

  cidr_blocks = var.egress_cidr_blocks
  description = var.rule_egress_description

  from_port                = var.egress_from_port
  to_port                  = var.egress_to_port
  protocol                 = var.egress_protocol
  source_security_group_id = var.egress_source_security_group_id
}
