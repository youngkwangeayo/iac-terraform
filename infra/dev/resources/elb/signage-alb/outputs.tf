output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.singnage-alb.lb_arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.singnage-alb.dns_name
}

output "http_listener_arn" {
  description = "ARN of HTTP listener"
  value       = module.singnage-alb.http_arn
}

output "https_listener_arn" {
  description = "ARN of HTTPS listener"
  value       = module.singnage-alb.https_arn
}
