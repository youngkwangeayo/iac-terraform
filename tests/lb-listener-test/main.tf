terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.18.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

module "common" {
  source = "../../infra/modules/common-22"

  environment   = "dev"
  project_name  = "test"
  service_name  = "tmp"
}


module "listener_test" {
  source = "../../infra/modules/load-balancer/listener"
  name = module.common.common_name
  
  load_balancer_arn = "arn:aws:elasticloadbalancing:ap-northeast-2:xxxxxxxxxxxx:loadbalancer/app/alb-dev-test-tmp/xxxxxxxxxxxxxxxx"
  protocol = "HTTP"
  port = "80"

  routing_action = "redirect"

  tags = module.common.common_tags
}

module "listener_test_2" {
  source = "../../infra/modules/load-balancer/listener"
  name = module.common.common_name

  load_balancer_arn = "arn:aws:elasticloadbalancing:ap-northeast-2:xxxxxxxxxxxx:loadbalancer/app/alb-dev-test-tmp/xxxxxxxxxxxxxxxx"
  protocol = "HTTPS"
  port = "443"
  certificate_arn = "arn:aws:acm:ap-northeast-2:xxxxxxxxxxxx:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  routing_action = "fixed-response"


  tags = module.common.common_tags
}

