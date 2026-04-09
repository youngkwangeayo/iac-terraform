
#   사용법
#  data.terraform_remote_state.route53_cms.outputs.dns_names["cms"]
#  data.terraform_remote_state.route53_cms.outputs.dns_values["cms"]

output "dns_names" {
  description = "alias => FQDN 맵"
  value       = { for k, v in aws_route53_record.this : k => v.fqdn }
}

output "dns_values" {
  description = "alias => CNAME 대상(레코드 값) 맵"
  value       = { for k, v in aws_route53_record.this : k => v.records }
}
