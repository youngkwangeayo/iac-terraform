
output "this" {
  description = "this "
  value = aws_lb.this
}
output "dns_name" {
  description = "DNS Name "
  value = aws_lb.this.dns_name
}
output "arn" {
  description = "this "
  value = aws_lb.this.arn
}