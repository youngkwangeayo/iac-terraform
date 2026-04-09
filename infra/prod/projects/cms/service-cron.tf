
# ============================================================================
# ECS Service Cron
# ============================================================================

module "ecs_service_cron" {
  source = "../../../modules/ecs/ecs-service"

  name                = "${module.common.common_name}-cron"
  cluster_id          = module.ecs_cluster.cluster_arn
  task_definition_arn = module.ecs_task_definition_cron.task_definition_arn
  desired_count       = 1
  platform_version    = "LATEST"
  scheduling_strategy = "REPLICA"

  capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 0
    }
  ]

  network_configuration = {
    subnets          = data.terraform_remote_state.network.outputs.private_subnet_ids
    security_groups  = [module.ecs_security_group.security_group_id, var.allowed_security_group_ids]
    assign_public_ip = true
  }

  deployment_configuration = {
    maximum_percent         = 200
    minimum_healthy_percent = 100
    deployment_circuit_breaker = {
      enable   = true
      rollback = true
    }
  }

  enable_execute_command  = true
  enable_ecs_managed_tags = true
  propagate_tags          = "NONE"

  tags = module.common.common_tags
}

# ============================================================================
# ECS Task Definition Cron
# ============================================================================

module "ecs_task_definition_cron" {
  source = "../../../modules/ecs/ecs-task-definition"

  family                   = "${module.common.common_name}-cron"
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = data.terraform_remote_state.iam.outputs.ecs_task_role_arn
  execution_role_arn       = data.terraform_remote_state.iam.outputs.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-cron"
      image     = var.container_image_url != null ? "${var.container_image_url}:${var.container_image_tag}" : "${module.ecr[0].repository_url}:${var.container_image_tag}"
      cpu       = 0
      essential = true


      environment = concat(
        [
          for k, v in var.environment_vars : {
            name  = k
            value = v
          }
        ],
        [
          {
            name  = "CRON"
            value = "ENABLE"
          }
        ]
      )

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "pgrep -f 'node' || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 2
        startPeriod = 90
      }

      startTimeout = 90
      stopTimeout  = 120
    }
  ])

  runtime_platform = {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  tags = module.common.common_tags
}