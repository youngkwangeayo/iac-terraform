# ============================================================================
# 프로젝트 정보
# ============================================================================

variable "name" {
  description = "loadbalancer name"
  type = string
}


variable "tags" {
  description = "A map of tags to add to the security group"
  type        = map(string)
  default     = {}
}


# ============================================================================
# 로드밸런서 정보
# ============================================================================


variable "subnet_ids" {
  type        = list(string)
  description = "서브넷. 가용영역 선택"
}

variable "security_groups" {
  type        = list(string)
  description = "보안그룹 적용"
}


variable "subnet_ids" {
  
}

variable "security_groups" {
  
}


# ============================================================================
# 로드밸런서 정보.   리스너 정보.
# ============================================================================

variable "certificate_arn" {
  description = "SSL/TSL 인증서 arn"
  type = string
  default = null
  validation {
    condition = !(var.protocol == "HTTPS" && var.certificate_arn == null)
    error_message = "HTTPS 는 CERT(SSL/TSL) 인증서 필수입니다."
  }
}

variable "additional_certificate_arn" {
  description = "443 ssl/tls 추가 인증서."
  type = list(string)
  default = []
}

