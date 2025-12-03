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
    
    # 옵션1 타입 타겟그룹
    target_group_arn = var.target_group_arn #defalut null

    # 옵션2 타입 리다이렉션
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

    # 옵션3 타입 고정응답 
    dynamic "fixed_response" {
      for_each = var.routing_action == "fixed_response" ? [1] : [0]
      content {
        content_type = var.fixed_response.content_type
        message_body = var.fixed_response.message_body
        status_code  = var.fixed_response.status_code
      }
    }
  }

  tags = var.tags
}


