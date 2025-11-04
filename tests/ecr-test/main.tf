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

module "aws_ecr" {
  source = "../../infra/dev/modules/ecr"

  repository_name      = "test-ecr-repo"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true

  tags = {
    Environment = "test"
    Project     = "test"
    ManagedBy   = "Terraform"
  }
}

output "repository_url" {
  value = module.aws_ecr.repository_url
}

output "repository_arn" {
  value = module.aws_ecr.repository_arn
}
