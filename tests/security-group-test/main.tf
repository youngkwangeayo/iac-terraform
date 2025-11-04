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

module "security_group" {
  source = "../../infra/modules/security-group"

  name        = "test-sg"
  description = "Test security group for ECS"
  vpc_id      = "vpc-12345678"

  ingress_rules = [
    {
      from_port       = 3827
      to_port         = 3827
      protocol        = "tcp"
      security_groups = ["sg-alb123"]
      description     = "Allow traffic from ALB"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "Allow HTTPS from VPC"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  ]

  tags = {
    Environment = "test"
    Project     = "test"
  }
}

output "security_group_id" {
  value = module.security_group.security_group_id
}

output "security_group_arn" {
  value = module.security_group.security_group_arn
}
