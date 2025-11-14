
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

variable "load_balancer_type" {
  description = "application or network"
  type        = string
  default     = "application"
  validation {
    condition     = var.load_balancer_type == null || contains(["application", "network"], var.load_balancer_type)
    error_message = "only application or network"
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "서브넷. 가용영역 선택"
}

variable "security_groups" {
  type        = list(string)
  description = "보안그룹 적용"
}


# ============================================================================
# 고급설정
# ============================================================================

variable "internal" {
  description = "내부로드밸런서 사용"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "terrform에서 삭제 못시키게 설정"
  type        = bool
  default     = false
}
