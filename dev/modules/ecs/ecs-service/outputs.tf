output "service_id" {
  description = "ID of the ECS service"
  value       = aws_ecs_service.this.id
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.this.name
}

output "service_cluster" {
  description = "ARN of the cluster which the service runs on"
  value       = aws_ecs_service.this.cluster
}

output "desired_count" {
  description = "Number of instances of the task definition"
  value       = aws_ecs_service.this.desired_count
}
