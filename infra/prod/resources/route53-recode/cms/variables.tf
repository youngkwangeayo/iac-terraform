# ============================================================================
# Project Info
# ============================================================================
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Environment (dev, stg, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "additional_tags" {
  description = "추가 태그"
  type        = map(string)
  default     = {}
}


# ============================================================================
# Route53 Configuration
# ============================================================================
variable "route53_records" {
  description = "Route53 CNAME records to create (여러 도메인/존 지원)"
  type = list(object({
    alias   = string
    zone_id = string
    name    = string
    records = list(string)
    ttl     = optional(number, 300)
  }))
  default = []
}

