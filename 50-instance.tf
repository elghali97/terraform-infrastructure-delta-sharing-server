# ================================================================================================================
# INSTANCES
# ================================================================================================================

// ------------- Servers ---------------
resource "aws_instance" "delta_sharing_instance" {
  count = length(aws_subnet.private_subnets)

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.large"

  iam_instance_profile   = aws_iam_instance_profile.app.name
  vpc_security_group_ids = [aws_security_group.main_instance_sg.id]
  subnet_id      = element(values(aws_subnet.private_subnets)[*].id, count.index)
  
  associate_public_ip_address = false

  user_data = templatefile(
    "./scripts/install-delta-share.tpl",
    {
      bearer_token  = "faaie590d541265bcab1f2de9813274bf233",
      data_provider = "palantir",
      palantir_dataset       = var.palantir_dataset_name,
      palantir_dataset_rid   = var.palantir_dataset_id,
      palantir_access_key_id = var.palantir_access_key_id,
      palantir_secret_access_key = var.palantir_secret_access_key,
      palantir_endpoint = var.palantir_endpoint,
      palantir_region = var.palantir_region
    }
  )


  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:project"]}-vm-${var.environment}" })

  lifecycle {
    ignore_changes = [user_data]
  }
}