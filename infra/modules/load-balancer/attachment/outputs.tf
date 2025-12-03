output "attachment_ids" {
  description = "Map of target attachment IDs"
  value = {
    for k, v in aws_lb_target_group_attachment.this :
    k => v.id
  }
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = var.target_group_arn
}

output "attached_targets" {
  description = "Map of attached target information"
  value = {
    for k, v in aws_lb_target_group_attachment.this :
    k => {
      target_id = v.target_id
      port      = v.port
    }
  }
}

output "attachment_count" {
  description = "Number of targets attached to the target group"
  value       = length(aws_lb_target_group_attachment.this)
}
