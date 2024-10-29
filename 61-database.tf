# ================================================================================================================
# Database - NOT USED RIGHT NOW
# ================================================================================================================
/*
# RDS
resource "aws_db_subnet_group" "delta_sharing_db_subg" {
  name       = "fr-${local.tags["databricks:project"]}-db-subg-${var.environment}"
  subnet_ids = values(aws_subnet.internal_subnets)[*].id

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-db-subg-${var.environment}" })
}

# DB Instance
resource "aws_db_instance" "delta_sharing_db" {
  identifier             = "fr-${local.tags["databricks:project"]}-db-${var.environment}"
  allocated_storage      = 10
  storage_type           = "gp2"
  
  engine                 = "postgres"
  
  db_name                = "adiads${var.environment}"
  instance_class         = "db.t3.micro"
  
  vpc_security_group_ids = [aws_security_group.main_rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.delta_sharing_db_subg.name
  skip_final_snapshot    = true

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-db-${var.environment}" })
}
*/