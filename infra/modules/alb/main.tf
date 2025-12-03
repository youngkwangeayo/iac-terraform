
resource "aws_lb" "alb" {
  name = "alb-${var.name}"

  load_balancer_type = "application"

  subnets         = var.subnet_ids
  security_groups = var.security_groups

  tags = var.tags
}

resource "aws_lb_listener" "HTTP" {
  load_balancer_arn = aws_lb.alb.arn

  protocol = "HTTP"
  port     = "80"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      host        = "#{host}"
      path        = "/#{path}"
      query       = "/#{query}"
      status_code = "HTTP_301"
    }
  }
  tags = var.tags
}

resource "aws_lb_listener" "HTTPS" {
  load_balancer_arn = aws_lb.alb.arn

  protocol        = "HTTPS"
  port            = "443"
  certificate_arn = var.certificate_arn

  default_action {
    type = "fixed_response"

    fixed_response {
      content_type = "text/html"
      message_body = "501 Target Not Implemented"
      status_code  = "501"
    }
  }
  tags = var.tags
}


resource "aws_lb_listener_certificate" "example" {
  for_each = toset(var.additional_certificate_arn)

  listener_arn    = aws_lb_listener.HTTPS.arn
  certificate_arn = each.value
}
