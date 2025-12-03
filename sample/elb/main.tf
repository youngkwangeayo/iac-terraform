



module "common" {
  source       = "../common"
  environment  = "dev"
  project_name = "tmp"
  service_name = "test"
}


module "elb" {
  source = "../../infra/modules/load-balancer/elb"
  name   = module.common.common_name

  internal           = var.internal
  load_balancer_type = var.load_balancer_type

  subnet_ids      = var.security_groups
  security_groups = var.security_groups

  tags = module.common.common_tags
}



module "listener_HTTP" {
  source = "../../infra/modules/load-balancer/listener"
  count  = (var.load_balancer_type == null || var.load_balancer_type == "application") ? 1 : 0

  name = module.common.common_name

  load_balancer_arn = module.elb.arn
  protocol          = "HTTP"
  port              = "80"

  routing_action = "redirect"
  tags           = module.common.common_tags
}


module "listener_HTTPS" {
  source = "../../infra/modules/load-balancer/listener"
  count  = (var.load_balancer_type == null || var.load_balancer_type == "application") ? 1 : 0

  name = module.common.common_name

  load_balancer_arn = module.elb.arn
  protocol          = "HTTPS"
  port              = "443"
  certificate_arn   = var.certificate_arn


  routing_action = "fixed-response"


  tags = module.common.common_tags
}


resource "aws_lb_listener_certificate" "example" {
  for_each = toset(var.additional_certificate_arn)

  listener_arn    = module.listener_HTTPS[0].arn
  certificate_arn = each.value
}
