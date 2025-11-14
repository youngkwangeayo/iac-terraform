
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


module "aws_ecs_service" {
  source              = "../../infra/modules/ecs/ecs-service"
  name                = "test-svc"
  cluster_id          = "arn:aws:ecs:ap-northeast-2:xxxxxxxxxxxx:cluster/test"
  task_definition_arn = "arn:aws:ecs:ap-northeast-2:xxxxxxxxxxxx:task-definition/test:1"
  desired_count       = 1
  launch_type         = "FARGATE"
  platform_version    = "LATEST"
  scheduling_strategy = "REPLICA"

  network_configuration = {
    subnets          = ["subnet-xxx"]
    security_groups  = ["sg-xxx"]
    assign_public_ip = true
  }

  capacity_provider_strategy = []
  load_balancer              = null

  deployment_configuration = {
    maximum_percent         = 200
    minimum_healthy_percent = 100
    deployment_circuit_breaker = {
      enable   = true
      rollback = true
    }
  }

  tags = {}

}
