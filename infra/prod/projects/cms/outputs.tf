# ============================================================================
# ECR Outputs
# ============================================================================

output "ecr_repository_url" {
  description = "URL of the ECR repository (null if using external image)"
  value       = var.container_image_url == null ? module.ecr[0].repository_url : null
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository (null if using external image)"
  value       = var.container_image_url == null ? module.ecr[0].repository_arn : null
}

# ============================================================================
# Security Group Outputs
# ============================================================================

output "ecs_security_group_id" {
  description = "ID of the ECS security group"
  value       = module.ecs_security_group.security_group_id
}

# ============================================================================
# Target Group Outputs
# ============================================================================

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.target_group.target_group_arn
}

output "target_group_name" {
  description = "Name of the target group"
  value       = module.target_group.target_group_name
}

# ============================================================================
# ECS Cluster Outputs
# ============================================================================

output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.ecs_cluster.cluster_id
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs_cluster.cluster_arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_cluster.cluster_name
}

# ============================================================================
# ECS Task Definition Outputs
# ============================================================================

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = module.ecs_task_definition.task_definition_arn
}

output "task_definition_family" {
  description = "Family of the task definition"
  value       = module.ecs_task_definition.task_definition_family
}

output "task_definition_revision" {
  description = "Revision of the task definition"
  value       = module.ecs_task_definition.task_definition_revision
}

# ============================================================================
# ECS Service Outputs
# ============================================================================

output "ecs_service_id" {
  description = "ID of the ECS service"
  value       = module.ecs_service.service_id
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs_service.service_name
}

output "ecs_service_cluster" {
  description = "ARN of the cluster which the service runs on"
  value       = module.ecs_service.service_cluster
}

# ============================================================================
# CloudWatch Log Group Output
# ============================================================================

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs.name
}
