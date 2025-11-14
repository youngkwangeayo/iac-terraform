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

  environment  = "dev"
  project_name = "test"
  service_name = "tmp"
}

module "tg_test" {
  source = "../../infra/modules/load-balancer/target-group"
  name   = module.common.common_name

  port     = null
  protocol = null
  vpc_id   = null

  target_type  = "lambda"
  health_check = null

  tags = module.common.common_tags
}
