# modules/ecs/task-definition/outputs.tf

output "task_definition_arn" {
  value       = aws_ecs_task_definition.this.arn
  description = "Task definition ARN"
}

output "task_definition_family" {
  value       = aws_ecs_task_definition.this.family
  description = "Task definition family"
}

output "task_definition_revision" {
  value       = aws_ecs_task_definition.this.revision
  description = "Task definition revision"
}
