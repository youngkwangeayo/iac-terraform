# ============================================================================
# 프로젝트 정보
# ============================================================================
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
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
# EC2 인스턴스
# ============================================================================
variable "ec2_instance_id" {
  description = "Signage EC2 인스턴스 ID"
  type        = string
}

# ============================================================================
# Route53 / DNS 설정
# ============================================================================
variable "route53_zone_id" {
  description = "Route53 Hosted Zone ID for nextpay.co.kr"
  type        = string
  default     = "Z075035514XCM0YECN764"
}

variable "app2_host_header" {
  description = "app2 솔루션 도메인 (Route53 레코드명)"
  type        = string
}

variable "app1_host_header" {
  description = "app1 솔루션 도메인 (Route53 레코드명)"
  type        = string
}

# ============================================================================
# app2 솔루션 설정
# ============================================================================
variable "app2_target_port" {
  description = "app2 타겟 포트"
  type        = number
}

variable "app2_health_check_path" {
  description = "app2 헬스체크 경로"
  type        = string
  default     = "/"
}

variable "app2_listener_rule_priority" {
  description = "app2 ALB 리스너 규칙 우선순위"
  type        = number
}

# ============================================================================
# app1 솔루션 설정
# ============================================================================
variable "app1_target_port" {
  description = "app1 타겟 포트"
  type        = number
}

variable "app1_health_check_path" {
  description = "app1 헬스체크 경로"
  type        = string
  default     = "/"
}

variable "app1_listener_rule_priority" {
  description = "app1 ALB 리스너 규칙 우선순위"
  type        = number
}
