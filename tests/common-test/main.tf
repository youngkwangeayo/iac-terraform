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
  source = "../../infra/modules/common"

  environment  = "dev"
  project_name = "test"
  service_name = "tmp"
}


output "common_name" {
  value = module.common.common_name
}

output "common_tags" {
  value = module.common.common_tags
}

output "environment" {
  value = module.common.environment
}
