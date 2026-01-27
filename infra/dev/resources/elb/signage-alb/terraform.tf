terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.18.0"
    }
  }

  backend "s3" {
    bucket         = "nextpay-terraform-state"
    key            = "dev/resources/elb/signage-alb/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "nextpay-terraform-locks"
    encrypt        = true
  }
  
}

provider "aws" {
  region = var.aws_region
}
