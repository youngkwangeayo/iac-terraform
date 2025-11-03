# modules/ecs/service/main.tf

resource "aws_ecs_service" "this" {
  name            = "${var.project}-${var.env}-${var.service_name}"
  cluster         = var.cluster_id
  task_definition = var.task_definition_arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type != "" ? var.launch_type : null

  platform_version = var.platform_version

  # Capacity Provider Strategy (Fargate와 Fargate Spot 혼합 사용 가능)
  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = lookup(capacity_provider_strategy.value, "weight", null)
      base              = lookup(capacity_provider_strategy.value, "base", null)
    }
  }

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = var.assign_public_ip
  }

  # Load Balancer 연결
  dynamic "load_balancer" {
    for_each = var.load_balancers
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  # 배포 설정
  deployment_configuration {
    # maximum_percent         = var.deployment_maximum_percent
    # minimum_healthy_percent = var.deployment_minimum_healthy_percent

    # deployment_circuit_breaker {
    #   enable   = var.enable_circuit_breaker
    #   rollback = var.enable_rollback
    # }
  }
  

  health_check_grace_period_seconds = var.health_check_grace_period_seconds
  scheduling_strategy               = var.scheduling_strategy
  enable_execute_command            = var.enable_execute_command
  enable_ecs_managed_tags           = var.enable_ecs_managed_tags
  propagate_tags                    = var.propagate_tags

  tags = merge(
    {
      Name = "${var.project}-${var.env}-${var.service_name}"
    },
    var.extra_tags
  )

  # lifecycle 설정으로 task_definition 변경 시 재생성 방지
  lifecycle {
    ignore_changes = [task_definition]
  }
}
