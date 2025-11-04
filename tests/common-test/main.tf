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

module "common_basic" {
  source = "../../infra/modules/common"

  environment  = "dev"
  project_name = "test"
}

module "common_full" {
  source = "../../infra/modules/common"

  environment  = "dev"
  project_name = "cms"
  aws_service  = "ecs"
  component    = "api"
  
  additional_tags = {
    Team = "platform"
    Cost = "shared"
  }
}

output "basic_name_prefix" {
  value = module.common_basic.name_prefix
}

output "basic_tags" {
  value = module.common_basic.common_tags
}

output "full_name_prefix" {
  value = module.common_full.name_prefix
}

output "full_tags" {
  value = module.common_full.common_tags
}
