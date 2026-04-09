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


variable "additional_tags" {
  description = "추가 태그"
  type        = map(string)
  default     = {}
}

# # ============================================================================
# # EC2 인스턴스
# # ============================================================================
# variable "ec2_instance_id" {
#   description = "Signage EC2 인스턴스 ID"
#   type        = string
# }

# ============================================================================
# Route53 / DNS 설정
# ============================================================================
variable "route53_zone_id" {
  description = "Route53 Hosted Zone ID for nextpay.co.kr"
  type        = string
  default     = "Z075035514XCM0YECN764"
}

variable "sm_backend_host_header" {
  description = "SM Backend 솔루션 도메인 (Route53 레코드명)"
  type        = string
}

variable "sm_frontend_host_header" {
  description = "SM Frontend 솔루션 도메인 (Route53 레코드명)"
  type        = string
}

variable "sm_cms_host_header" {
  description = "SM CMS 솔루션 도메인 (Route53 레코드명)"
  type        = string
}

variable "signage-hub_host_header" {
  description = "SIGNAGE HUB 솔루션 도메인 (Route53 레코드명)"
  type        = string
}

variable "scms_host_header" {
  description = "SCMS 솔루션 도메인 (Route53 레코드명)"
  type        = string
}

variable "sw_host_header" {
  description = "SW 솔루션 도메인 (Route53 레코드명)"
  type        = string
}

# # ============================================================================
# # SM Backend 솔루션 설정
# # ============================================================================
# variable "sm_backend_target_port" {
#   description = "SM Backend 타겟 포트"
#   type        = number
# }

# variable "sm_backend_health_check_path" {
#   description = "SM Backend 헬스체크 경로"
#   type        = string
#   default     = "/"
# }

# variable "sm_backend_listener_rule_priority" {
#   description = "SM Backend ALB 리스너 규칙 우선순위"
#   type        = number
# }

# # ============================================================================
# # SM Frontend 솔루션 설정
# # ============================================================================
# variable "sm_frontend_target_port" {
#   description = "SM Frontend 타겟 포트"
#   type        = number
# }

# variable "sm_frontend_health_check_path" {
#   description = "SM Frontend 헬스체크 경로"
#   type        = string
#   default     = "/"
# }

# variable "sm_frontend_listener_rule_priority" {
#   description = "SM Frontend ALB 리스너 규칙 우선순위"
#   type        = number
# }

# # ============================================================================
# # SM CMS 솔루션 설정
# # ============================================================================

# variable "sm_cms_target_port" {
#   description = "SM CMS 타겟 포트"
#   type        = number
# }

# variable "sm_cms_health_check_path" {
#   description = "SM CMS 헬스체크 경로"
#   type        = string
#   default     = "/"
# }

# variable "sm_cms_listener_rule_priority" {
#   description = "SM CMS ALB 리스너 규칙 우선순위"
#   type        = number
# }

# # ============================================================================
# # SCMS 솔루션 설정
# # ============================================================================

# variable "scms_target_port" {
#   description = "SCMS 타겟 포트"
#   type        = number
# }

# variable "scms_health_check_path" {
#   description = "SCMS 헬스체크 경로"
#   type        = string
#   default     = "/"
# }

# variable "scms_listener_rule_priority" {
#   description = "SCMS ALB 리스너 규칙 우선순위"
#   type        = number
# }

# # ============================================================================
# # SW 솔루션 설정
# # ============================================================================

# variable "sw_target_port" {
#   description = "SW 타겟 포트"
#   type        = number
# }

# variable "sw_health_check_path" {
#   description = "SW 헬스체크 경로"
#   type        = string
#   default     = "/"
# }

# variable "sw_listener_rule_priority" {
#   description = "SW ALB 리스너 규칙 우선순위"
#   type        = number
# }
