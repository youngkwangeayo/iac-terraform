resource "aws_ecs_task_definition" "this" {
  family                   = "task-${var.family}"
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
  container_definitions    = var.container_definitions

  runtime_platform {
    cpu_architecture        = var.runtime_platform.cpu_architecture
    operating_system_family = var.runtime_platform.operating_system_family
  }

  tags = merge(
    var.tags,
    { Name = "task-${var.family}" }
  )

  lifecycle {
    ignore_changes = [container_definitions]
  }
}
