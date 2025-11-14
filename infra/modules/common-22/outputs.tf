

output "common_name" {
  description = "<project_name>-<sercice_name>"
  value       = local.common_name
}

# output "common_full_name" {
#   description = "<모듈에서 선택된 리소스>-<project_name>-<sercice_name>"
#   value       = "resource-${local.common_name}"
# }

output "common_tags" {
  description = "Common tags for all resources"
  value       = local.common_tags
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}
