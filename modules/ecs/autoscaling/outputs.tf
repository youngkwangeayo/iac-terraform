# modules/ecs/autoscaling/outputs.tf

output "scalable_target_id" {
  value       = aws_appautoscaling_target.this.id
  description = "Scalable target ID"
}

output "cpu_policy_arn" {
  value       = var.enable_cpu_scaling ? aws_appautoscaling_policy.cpu[0].arn : null
  description = "CPU scaling policy ARN"
}

output "memory_policy_arn" {
  value       = var.enable_memory_scaling ? aws_appautoscaling_policy.memory[0].arn : null
  description = "Memory scaling policy ARN"
}
