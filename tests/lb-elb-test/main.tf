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


module "alb" {
  source = "../../infra/modules/load-balancer/elb"

  name        = module.common.common_name

  load_balancer_type = null

  subnet_ids      = ["subnet-xxxxxxxxxx", "subnet-yyyyyyyyyy"]
  security_groups = ["sg-xxxxxxxxxxxxxxxxx"]
  
  tags = module.common.common_tags
}

module "nlb" {
  source = "../../infra/modules/load-balancer/elb"

  name        = module.common.common_name

  load_balancer_type = "network"
  internal = true

  subnet_ids      = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-yyyyyyyyyyyyyyyyy"]
  security_groups = ["sg-xxxxxxxxxxxxxxxxx"]

  
  tags = module.common.common_tags
}


