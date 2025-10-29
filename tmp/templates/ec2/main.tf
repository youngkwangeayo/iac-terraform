terraform {
  required_version = ">= 1.9.0"
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


module "data" {
  source   = "../../modules/resources"
  vpc_name = "하드코딩:dev_vpc"
}

module "ec2" {
  source = "../../modules/ec2"

  env           = "하드코딩:dev"
  instance_name = "하드코딩:terraform-test"
  project="하드코딩:terraform"

  instance_type = "하드코딩:t3.micro"
  ami_type      = "하드코딩:ubuntu"
  volume_size = 20//하드코딩:
  volume_type = "하드코딩:gp3"

  key_name = "하드코딩:nextpay.dev.pem"

  subnet_id           = "하드코딩:subnet-1234"
  security_group_ids  = ["하드코딩:sg-0d856c4c37acc59c5"]
  associate_public_ip = false//하드코딩:
  
}

