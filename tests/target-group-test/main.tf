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

module "target_group" {
  source = "../../infra/modules/target-group"

  name        = "test-tg"
  port        = 3827
  protocol    = "HTTP"
  vpc_id      = "vpc-12345678"
  target_type = "ip"

  health_check = {
    enabled             = true
    path                = "/api/ping"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  deregistration_delay = 30

  tags = {
    Environment = "test"
    Project     = "cms"
  }
}

output "target_group_arn" {
  value = module.target_group.target_group_arn
}

output "target_group_name" {
  value = module.target_group.target_group_name
}
