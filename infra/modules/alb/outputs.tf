
output "alb" {
  description = "alb "
  value = aws_lb.alb
}
output "dns_name" {
  description = "DNS Name "
  value = aws_lb.alb.dns_name
}
output "lb_arn" {
  description = "alb "
  value = aws_lb.alb.arn
}


output "http_arn" {
  description = "http arn"
  value = aws_lb_listener.HTTP.arn
}

output "https_arn" {
  description = "https_arn"
  value = aws_lb_listener.HTTPS.arn
}