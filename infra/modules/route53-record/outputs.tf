output "fqdn" {
  description = "Fully qualified domain name"
  value       = aws_route53_record.this.fqdn
}

output "name" {
  description = "Record name"
  value       = aws_route53_record.this.name
}

output "record_id" {
  description = "Route53 record ID"
  value       = aws_route53_record.this.id
}
