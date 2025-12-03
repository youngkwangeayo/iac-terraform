

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.listener_arn
  priority     = var.priority

  condition {
    host_header {
      values = [var.host_header_values]
    }
  }

  action {
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

}
