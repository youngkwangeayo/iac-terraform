output "name_prefix" {
  description = "Basic name prefix: {environment}-{project_name}"
  value       = local.base_prefix
}

output "service_prefix" {
  description = "Service name prefix: {environment}-{aws_service}-{project_name}"
  value       = local.service_prefix
}

output "full_name" {
  description = "Full resource name with component: {environment}-{aws_service}-{project_name}-{component}"
  value       = local.full_name
}

output "common_tags" {
  description = "Common tags for all resources"
  value       = local.common_tags
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}
