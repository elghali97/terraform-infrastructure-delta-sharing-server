# ================================================================================================================
# Networking
# ================================================================================================================

// ----------- VPC -----------
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags                 = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-vpc-${var.environment}" })
}

// --------------- Subnet ----------------
resource "aws_subnet" "public_subnets" {
  for_each = toset(var.availability_zones)

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 3, 3 * index(var.availability_zones, each.value))
  map_public_ip_on_launch = true
  availability_zone       = each.key

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-pub-subnet-${each.key}-${var.environment}" })
}

resource "aws_subnet" "private_subnets" {
  for_each = toset(var.availability_zones)

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 3, 3 * index(var.availability_zones, each.value) + 1)
  map_public_ip_on_launch = true
  availability_zone       = each.key

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-pri-subnet-${each.key}-${var.environment}" })
}

resource "aws_subnet" "internal_subnets" {
  for_each = toset(var.availability_zones)

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 3, 3 * index(var.availability_zones, each.value) + 2)
  map_public_ip_on_launch = true
  availability_zone       = each.key

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-int-subnet-${each.key}-${var.environment}" })
}

// ----------- Internet Gateway -----------
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-igw-${var.environment}" })
}

// -------------- NAT Gateway --------------
resource "aws_eip" "nat_ips" {
  for_each = toset(var.availability_zones)

  domain = "vpc"
  tags   = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-eip-${each.key}-${var.environment}" })

  depends_on = [
    aws_internet_gateway.main_igw
  ]
}

resource "aws_nat_gateway" "nat_gw" {
  count = length(aws_eip.nat_ips)

  allocation_id = element(values(aws_eip.nat_ips)[*].id, count.index)
  subnet_id     = element(values(aws_subnet.public_subnets)[*].id, count.index)

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-ngw-${element(var.availability_zones, count.index)}-${var.environment}" })
}

// ----------- Route table -----------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-pub-rt-${var.environment}" })
}

resource "aws_route_table_association" "public_rt_assoc" {
  count = length(aws_subnet.public_subnets)

  subnet_id      = element(values(aws_subnet.public_subnets)[*].id, count.index)
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_route_table" "private_rt" {
  for_each = toset(var.availability_zones)

  vpc_id = aws_vpc.main_vpc.id

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-pri-rt-${each.key}-${var.environment}" })
}

resource "aws_route" "private_natgw_route" {
  count = length(aws_nat_gateway.nat_gw)

  route_table_id         = element(values(aws_route_table.private_rt)[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat_gw[*].id, count.index)
}

resource "aws_route_table_association" "private_rt_assoc" {
  count = length(aws_subnet.private_subnets)

  subnet_id      = element(values(aws_subnet.private_subnets)[*].id, count.index)
  route_table_id = element(values(aws_route_table.private_rt)[*].id, count.index)
}

resource "aws_route_table" "internal_rt" {
  for_each = toset(var.availability_zones)

  vpc_id = aws_vpc.main_vpc.id

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-int-rt-${each.key}-${var.environment}" })
}

resource "aws_route_table_association" "internal_rt_assoc" {
  count = length(aws_subnet.internal_subnets)

  subnet_id      = element(values(aws_subnet.internal_subnets)[*].id, count.index)
  route_table_id = element(values(aws_route_table.internal_rt)[*].id, count.index)
}

// ----------- Endpoints SSM -----------

# VPC endpoint for the Systems Manager service
resource "aws_vpc_endpoint" "ssm_endpoint" {
  vpc_id              = aws_vpc.main_vpc.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private_subnets)[*].id
  security_group_ids  = [aws_security_group.ssm_endpoint_sg.id]
  private_dns_enabled = true

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-ssm-endpoint-${var.environment}" })
}

# VPC endpoint for SSM Agent to make calls to the Systems Manager service
resource "aws_vpc_endpoint" "ec2_messages_endpoint" {
  vpc_id              = aws_vpc.main_vpc.id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private_subnets)[*].id
  security_group_ids  = [aws_security_group.ssm_endpoint_sg.id]
  private_dns_enabled = true

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-ec2-messages-endpoint-${var.environment}" })
}

# VPC endpoint for connecting to EC2 instances through a secure data channel using Session Manager
resource "aws_vpc_endpoint" "ssm_messages_endpoint" {
  vpc_id              = aws_vpc.main_vpc.id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private_subnets)[*].id
  security_group_ids  = [aws_security_group.ssm_endpoint_sg.id]
  private_dns_enabled = true

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-ssm-messages-endpoint-${var.environment}" })
}