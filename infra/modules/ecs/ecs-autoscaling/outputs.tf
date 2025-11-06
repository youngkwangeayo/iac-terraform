output "autoscaling_target_id" {
  description = "Autoscaling target resource ID"
  value       = aws_appautoscaling_target.this.id
}

output "autoscaling_policy_arn" {
  description = "Autoscaling policy ARN"
  value       = aws_appautoscaling_policy.this.arn
}

output "autoscaling_policy_name" {
  description = "Autoscaling policy name"
  value       = aws_appautoscaling_policy.this.name
}
