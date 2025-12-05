resource "aws_ecs_service" "this" {
  name                               = "service-${var.name}"
  cluster                            = var.cluster_id
  task_definition                    = var.task_definition_arn
  desired_count                      = var.desired_count
  launch_type                        = var.launch_type
  platform_version                   = var.platform_version
  scheduling_strategy                = var.scheduling_strategy
  health_check_grace_period_seconds  = var.load_balancer != null ? var.health_check_grace_period_seconds : null
  enable_execute_command             = var.enable_execute_command
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  propagate_tags                     = var.propagate_tags

  network_configuration {
    subnets          = var.network_configuration.subnets
    security_groups  = var.network_configuration.security_groups
    assign_public_ip = var.network_configuration.assign_public_ip
  }

  dynamic "deployment_configuration" {
    for_each = var.deployment_strategy == "BLUE_GREEN" ? [1] : []
    content {
      strategy = "BLUE_GREEN"
    }
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer != null ? [var.load_balancer] : []
    
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
     
      dynamic "advanced_configuration" {
        for_each = var.blue_green_deployment != null ? [var.blue_green_deployment] : []
        content {
          alternate_target_group_arn = advanced_configuration.value.alternate_target_group_arn
          production_listener_rule = advanced_configuration.value.production_listener_rule
          role_arn = advanced_configuration.value.role_arn
        }
      }

    }

  }

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
      base              = capacity_provider_strategy.value.base
    }
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = var.deployment_configuration.deployment_circuit_breaker.enable
    rollback = var.deployment_configuration.deployment_circuit_breaker.rollback
  }

  deployment_maximum_percent         = var.deployment_configuration.maximum_percent
  deployment_minimum_healthy_percent = var.deployment_configuration.minimum_healthy_percent

  tags = merge(
    var.tags,
    { Name : "service-${var.name}" }
  )

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
}
