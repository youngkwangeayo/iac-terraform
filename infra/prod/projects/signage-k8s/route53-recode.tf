
resource "aws_route53_record" "this" {
  for_each = { for r in var.route53_records : r.name => r }

  zone_id = each.value.zone_id
  name    = each.value.name
  type    = "CNAME"
  ttl     = 300
  records = each.value.records
}
