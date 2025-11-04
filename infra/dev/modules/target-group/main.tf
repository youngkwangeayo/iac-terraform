resource "aws_lb_target_group" "this" {
  name                 = var.name
  port                 = var.port
  protocol             = var.protocol
  vpc_id               = var.vpc_id
  target_type          = var.target_type
  deregistration_delay = var.deregistration_delay

  health_check {
    enabled             = var.health_check.enabled
    path                = var.health_check.path
    port                = var.health_check.port
    protocol            = var.health_check.protocol
    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
    timeout             = var.health_check.timeout
    interval            = var.health_check.interval
    matcher             = var.health_check.matcher
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}
