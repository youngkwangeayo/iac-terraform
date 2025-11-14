output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.this.arn
}

output "target_group_id" {
  description = "ID of the target group"
  value       = aws_lb_target_group.this.id
}

output "target_group_name" {
  description = "Name of the target group"
  value       = aws_lb_target_group.this.name
}

output "target_group_arn_suffix" {
  description = "ARN suffix for use with CloudWatch Metrics"
  value       = aws_lb_target_group.this.arn_suffix
}
