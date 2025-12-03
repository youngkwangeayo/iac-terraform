

resource "aws_lb_target_group_attachment" "this" {
  for_each = {
    for k, v in var.target :
    k => v
  }
  target_group_arn = var.target_group_arn

  target_id        = each.value.target_id
  port             = each.value.port
}
