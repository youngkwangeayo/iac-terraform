output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = data.aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = data.aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = data.aws_lb.main.zone_id
}

output "http_listener_arn" {
  description = "ARN of HTTP listener"
  value       = try(data.aws_lb_listener.http.arn, null)
}

output "https_listener_arn" {
  description = "ARN of HTTPS listener"
  value       = try(data.aws_lb_listener.https.arn, null)
}

output "vpc_id" {
  description = "VPC ID where ALB is located"
  value       = data.aws_lb.main.vpc_id
}

output "security_groups" {
  description = "Security groups attached to ALB"
  value       = data.aws_lb.main.security_groups
}
