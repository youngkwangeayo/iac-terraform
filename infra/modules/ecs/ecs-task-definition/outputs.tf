output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.this.arn
}

output "task_definition_family" {
  description = "Family of the task definition"
  value       = aws_ecs_task_definition.this.family
}

output "task_definition_revision" {
  description = "Revision of the task definition"
  value       = aws_ecs_task_definition.this.revision
}

output "task_definition_arn_without_revision" {
  description = "ARN of the task definition without revision"
  value       = replace(aws_ecs_task_definition.this.arn, "/:${aws_ecs_task_definition.this.revision}$/", "")
}
