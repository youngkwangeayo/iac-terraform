# ============================================================================
# 어플리케이션 로드밸런서는 리스너에 대상그룹 선택
# 네트워크 로드밸런서는 리스너에 대상그룹 필수
# ============================================================================

resource "aws_lb_listener" "this" {
  load_balancer_arn = var.load_balancer_arn

  protocol = var.protocol
  port     = var.port
  certificate_arn = var.certificate_arn #defalut null

  default_action {
    type             = var.routing_action
    
    target_group_arn = var.target_group_arn #defalut null

    dynamic "redirect" {
      for_each = var.routing_action == "redirect" ? [1] : [0]
      content {
        port        = var.redirect.port
        protocol    = var.redirect.protocol
        host        = var.redirect.host
        path        = var.redirect.path
        query       = var.redirect.query
        status_code = var.redirect.status_code
      }
    }

    dynamic "fixed_response" {
      for_each = var.routing_action == "fixed_response" ? [1] : [0]
      content {
        content_type = "text/plain"
        message_body = "Fixed response content"
        status_code  = "200"
      }
    }
  }

  tags = var.tags
}


# resource "aws_lb_listener" "this" {
#   load_balancer_arn = var.load_balancer_arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.front_end.arn
#   }
# }


# resource "aws_lb_listener" "front_end" {
#   load_balancer_arn = aws_lb.front_end.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"

#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }

# resource "aws_lb_listener" "front_end" {
#   load_balancer_arn = aws_lb.front_end.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type = "fixed-response"

#     fixed_response {
#       content_type = "text/plain"
#       message_body = "Fixed response content"
#       status_code  = "200"
#     }
#   }
# }

# resource "aws_lb_listener" "front_end" {
#   load_balancer_arn = aws_lb.front_end.arn
#   port              = "443"
#   protocol          = "TLS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
#   alpn_policy       = "HTTP2Preferred"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.front_end.arn
#   }
# }
