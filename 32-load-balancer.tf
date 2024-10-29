# ================================================================================================================
# Load Balancer
# ================================================================================================================

resource "aws_lb" "delta_sharing_lb" {
  name               = "fr-${local.tags["databricks:short-name"]}-lb-${var.environment}"
  load_balancer_type = "application"
  internal           = false
  subnets            = values(aws_subnet.public_subnets)[*].id
  security_groups    = [aws_security_group.main_lb_sg.id]

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:short-name"]}-lb-${var.environment}" })
}

# Target Group
resource "aws_lb_target_group" "delta_sharing_tg" {
  name     =  "fr-${local.tags["databricks:short-name"]}-tg-${var.environment}"
  vpc_id   = aws_vpc.main_vpc.id
  port     = 8080
  protocol = "HTTP"
  
  health_check{
    enabled = true
    path = "/delta-sharing/shares"
  }
  

  tags = merge(local.tags, { "Name" = "fr-${local.tags["databricks:short-name"]}-tg-${var.environment}" })
}

# Targets
resource "aws_lb_target_group_attachment" "delta_sharing_targets" {
  count = length(aws_instance.delta_sharing_instance)

  target_group_arn = aws_lb_target_group.delta_sharing_tg.arn
  target_id        = lookup(element(aws_instance.delta_sharing_instance, count.index), "id")
}


# HTTP Listener
resource "aws_lb_listener" "delta_sharing_listen_http" {
  load_balancer_arn = aws_lb.delta_sharing_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.delta_sharing_tg.arn
  }
}