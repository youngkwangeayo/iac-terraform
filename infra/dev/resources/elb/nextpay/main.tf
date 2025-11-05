# Network State 참조 (dev-vpc)
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "nextpay-terraform-state"
    key    = "dev/resources/network/nextpay/terraform.tfstate"
    region = var.aws_region
  }
}

# 기존 ALB 참조
data "aws_lb" "main" {
  name = var.alb_name
}

# ALB 리스너 참조 (HTTP/HTTPS)
data "aws_lb_listener" "http" {
  load_balancer_arn = data.aws_lb.main.arn
  port              = 80
}

data "aws_lb_listener" "https" {
  load_balancer_arn = data.aws_lb.main.arn
  port              = 443
}

# Target Group 생성 (옵션)
resource "aws_lb_target_group" "this" {
  count = var.create_target_group ? 1 : 0

  name        = var.target_group_config.name
  port        = var.target_group_config.port
  protocol    = var.target_group_config.protocol
  vpc_id      = data.aws_lb.main.vpc_id
  target_type = var.target_group_config.target_type

  health_check {
    enabled             = var.target_group_config.health_check.enabled
    path                = var.target_group_config.health_check.path
    port                = var.target_group_config.health_check.port
    protocol            = var.target_group_config.health_check.protocol
    healthy_threshold   = var.target_group_config.health_check.healthy_threshold
    unhealthy_threshold = var.target_group_config.health_check.unhealthy_threshold
    timeout             = var.target_group_config.health_check.timeout
    interval            = var.target_group_config.health_check.interval
    matcher             = var.target_group_config.health_check.matcher
  }

  tags = {
    Name = var.target_group_config.name
  }
}

# HTTPS 리스너 규칙 추가 (옵션)
resource "aws_lb_listener_rule" "https" {
  count = var.create_target_group && length(var.listener_rule_conditions) > 0 ? 1 : 0

  listener_arn = data.aws_lb_listener.https.arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }

  dynamic "condition" {
    for_each = var.listener_rule_conditions

    content {
      dynamic "path_pattern" {
        for_each = condition.value.path_pattern != null ? [condition.value.path_pattern] : []
        content {
          values = path_pattern.value
        }
      }

      dynamic "host_header" {
        for_each = condition.value.host_header != null ? [condition.value.host_header] : []
        content {
          values = host_header.value
        }
      }
    }
  }
}
