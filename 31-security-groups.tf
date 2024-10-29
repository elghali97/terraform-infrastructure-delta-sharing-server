# ================================================================================================================
# Security Groups
# ================================================================================================================

// ----------- Instances Security Group -----------
resource "aws_security_group" "main_instance_sg" {
  name        = "fr-${local.tags["databricks:project"]}-sg-${var.environment}"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "HTTPS user access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    description = "HTTP user access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    description = "Direct Delta Sharing user access"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.main_lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-sg-${var.environment}" })
}

// ----------- Load Balancer Security Group -----------
resource "aws_security_group" "main_lb_sg" {
  name        = "fr-${local.tags["databricks:project"]}-lb-sg-${var.environment}"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "HTTPS user access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    description = "HTTPS access from Databricks control plane"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.databricks_control_plane_ips[var.region]
  }

  ingress {
    description = "HTTP user access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    description = "HTTPS access from Databricks control plane"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = local.databricks_control_plane_ips[var.region]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-lb-sg-${var.environment}" })
}

// ----------- Database Security Group -----------
resource "aws_security_group" "main_rds_sg" {
  name        = "fr-${local.tags["databricks:project"]}-rds-sg-${var.environment}"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "HTTPS user access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-rds-sg-${var.environment}" })
}

// ----------- SSM Endpoint Security Group -----
resource "aws_security_group" "ssm_endpoint_sg" {
  name        = "fr-${local.tags["databricks:project"]}-ssm-sg-${var.environment}"
  description = "Allow TLS inbound traffic for SSM/EC2 endpoints"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
  
  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-ssm-sg-${var.environment}" })
}