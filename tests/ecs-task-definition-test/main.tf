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

module "ecs_task_definition" {
  source = "../../infra/modules/ecs/ecs-task-definition"

  family                   = "test-task"
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = "arn:aws:iam::123456789012:role/ecsTaskRole"
  execution_role_arn       = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name      = "test-app"
      image     = "nginx:latest"
      cpu       = 0
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "ENVIRONMENT"
          value = "test"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/test-task"
          "awslogs-region"        = "ap-northeast-2"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  runtime_platform = {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  tags = {
    Environment = "test"
    Project     = "test"
  }
}

output "task_definition_arn" {
  value = module.ecs_task_definition.task_definition_arn
}

output "task_definition_family" {
  value = module.ecs_task_definition.task_definition_family
}

output "task_definition_revision" {
  value = module.ecs_task_definition.task_definition_revision
}
