# modules/ecs/service/outputs.tf

output "service_id" {
  value       = aws_ecs_service.this.id
  description = "ECS service ID"
}

output "service_name" {
  value       = aws_ecs_service.this.name
  description = "ECS service name"
}

output "service_arn" {
  value       = aws_ecs_service.this.id
  description = "ECS service ARN"
}
