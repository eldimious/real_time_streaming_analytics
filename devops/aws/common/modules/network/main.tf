
locals {
  nat_gateway_count = var.single_nat_gateway ? 1 : length(var.availability_zones)

  vpc_id = concat(aws_vpc.this.*.id, [""])[0]
}

################################################################################
# VPC Definition
################################################################################
resource "aws_vpc" "this" {
  count                = var.create_vpc ? 1 : 0
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    Name        = "${var.project}_${var.environment}_vpc"
    Environment = var.environment
  }
}

################################################################################
# IG Definition
################################################################################
resource "aws_internet_gateway" "this" {
  count  = var.create_vpc && var.create_igw && length(var.public_subnet_cidrs) > 0 ? 1 : 0
  vpc_id = local.vpc_id
  tags = {
    Name        = "${var.project}_${var.environment}_ig"
    Environment = var.environment
  }
}

################################################################################
# Private Subnets Definition
################################################################################
# Create length(var.availability_zones) private subnets, each in a different AZ
resource "aws_subnet" "private" {
  count             = var.create_vpc && length(var.private_subnet_cidrs) > 0 ? length(var.private_subnet_cidrs) : 0
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  vpc_id            = local.vpc_id
  tags = merge(
    var.public_subnet_additional_tags,
    {
      Name        = "${var.project}_${var.environment}_private_subnet"
      Environment = var.environment
    }
  )
}

################################################################################
# Public Subnets Definition
################################################################################
# Create length(var.availability_zones) public subnets, each in a different AZ
resource "aws_subnet" "public" {
  count                   = var.create_vpc && length(var.public_subnet_cidrs) > 0 ? length(var.public_subnet_cidrs) : 0
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  vpc_id                  = local.vpc_id
  map_public_ip_on_launch = true
  tags = merge(
    var.public_subnet_additional_tags,
    {
      Name        = "${var.project}_${var.environment}_public_subnet"
      Environment = var.environment

    }
  )
}

################################################################################
# Public RT Definition
################################################################################
# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.this[0].main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

################################################################################
# NAT Definition
################################################################################
# Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity
resource "aws_eip" "nat" {
  count      = var.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0
  vpc        = true
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = var.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0
  subnet_id = element(
    aws_subnet.public.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )
  allocation_id = element(
    aws_eip.nat.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )
  depends_on = [aws_internet_gateway.this]
}

################################################################################
# Private RT Definition
################################################################################
# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  count  = length(var.availability_zones) # var.create_vpc ? local.nat_gateway_count : 0
  vpc_id = local.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.this.*.id, count.index)
  }
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones) # var.create_vpc ? local.nat_gateway_count : 0
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}
