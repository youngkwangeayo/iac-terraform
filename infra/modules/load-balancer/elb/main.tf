
locals {
  lb_name_prefix = (var.load_balancer_type == "application" || var.load_balancer_type == null ) ? "alb" : "nlb"
}

resource "aws_lb" "this" {
  name = "${local.lb_name_prefix}-${var.name}"

  internal           = var.internal           #default true
  load_balancer_type = var.load_balancer_type == null? "application" : var.load_balancer_type #default application

  subnets         = var.subnet_ids
  security_groups = var.security_groups

  tags = var.tags
}

# re

# module "lb" {
#   source = "value"
# }
