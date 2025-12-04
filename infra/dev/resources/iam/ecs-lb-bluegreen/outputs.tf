output "arn" {
  description = "ARN"
  value       = aws_iam_role.ecs_lb_blue_green.arn
}

output "role_name" {
  description = "Name of the Role"
  value       = aws_iam_role.ecs_lb_blue_green.name
}
