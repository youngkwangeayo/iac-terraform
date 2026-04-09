# ============================================================================
# 프로젝트 정보
# ============================================================================

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, stg, prod)"
  type        = string
  nullable    = false
  validation {
    condition     = contains(["dev", "stg", "prod"], var.environment)
    error_message = "dev, stg, prod 중 택1을 꼭 해주세요."
  }
}

# ============================================================================
# 도메인 / Route53 / ACM
# ============================================================================

variable "domain_name" {
  description = "CloudFront에 연결할 도메인"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 Hosted Zone ID"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM 인증서 ARN (us-east-1)"
  type        = string
}
