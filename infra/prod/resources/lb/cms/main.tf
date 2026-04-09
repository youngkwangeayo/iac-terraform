# Network State 참조 (dev-vpc)
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "nextpay-terraform-state"
    key    = "prod/resources/network/nextpay/terraform.tfstate"
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