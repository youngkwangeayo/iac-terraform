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

module "ecs_cluster" {
  source = "../../infra/modules/ecs/ecs-cluster"

  cluster_name        = "test-cluster"
  capacity_providers  = ["FARGATE", "FARGATE_SPOT"]
  container_insights  = "enhanced"

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 1
    }
  ]

  tags = {
    Environment = "test"
    Project     = "cms"
  }
}

output "cluster_id" {
  value = module.ecs_cluster.cluster_id
}

output "cluster_arn" {
  value = module.ecs_cluster.cluster_arn
}

output "cluster_name" {
  value = module.ecs_cluster.cluster_name
}
