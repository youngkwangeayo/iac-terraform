# modules/ecs/task-definition/main.tf

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project}-${var.env}-${var.task_family}"
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn

  runtime_platform {
    operating_system_family = var.operating_system_family
    cpu_architecture        = var.cpu_architecture
  }

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      cpu       = var.container_cpu
      essential = true

      portMappings = [
        for port in var.port_mappings : {
          containerPort = port.container_port
          hostPort      = port.host_port
          protocol      = lookup(port, "protocol", "tcp")
          name          = lookup(port, "name", "${var.container_name}-port")
          appProtocol   = lookup(port, "app_protocol", "http")
        }
      ]

      environment = [
        for key, value in var.environment_variables : {
          name  = key
          value = value
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.log_group_name != "" ? var.log_group_name : "/ecs/${var.project}-${var.env}-${var.task_family}"
          "awslogs-create-group"  = "true"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = var.health_check_command != "" ? {
        command     = ["CMD-SHELL", var.health_check_command]
        interval    = var.health_check_interval
        timeout     = var.health_check_timeout
        retries     = var.health_check_retries
        startPeriod = var.health_check_start_period
      } : null

      startTimeout = var.start_timeout
      stopTimeout  = var.stop_timeout
    }
  ])

  tags = merge(
    {
      Name = "${var.project}-${var.env}-${var.task_family}"
    },
    var.extra_tags
  )
}
