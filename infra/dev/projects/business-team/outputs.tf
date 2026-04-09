# ============================================================================
# Outputs
# ============================================================================

output "s3_bucket_name" {
  description = "S3 버킷 이름"
  value       = aws_s3_bucket.static.id
}

output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID (캐시 무효화 시 사용)"
  value       = aws_cloudfront_distribution.static.id
}

output "cloudfront_domain_name" {
  description = "CloudFront 도메인"
  value       = aws_cloudfront_distribution.static.domain_name
}

output "domain_name" {
  description = "서비스 도메인"
  value       = aws_route53_record.static.fqdn
}
