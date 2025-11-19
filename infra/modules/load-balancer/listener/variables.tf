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
# 로드밸런서 정보.   리스너 정보.
# ============================================================================
variable "load_balancer_arn" {
  description = "로드밸런서 arn 선택"
  type = string
}

variable "protocol" {
  description = "클라이언트에서 로드 밸런서로 연결하기 위해 사용"
  type = string
}

variable "port" {
  description = "로드 밸런서가 연결을 위해 수신 대기하는 포트"
  type = string
}

variable "routing_action" {
  description = "라우팅 액션.  [대상그룹,리다이렉션,고정반환] 중 택1"
  type = string
  validation {
    condition = contains(["forward","redirect","fixed-response"], var.routing_action)
    error_message = "Only forward, redirect, fixed-response"
  }
}

variable "certificate_arn" {
  description = "SSL/TSL 인증서 arn"
  type = string
  default = null
  validation {
    condition = !(var.protocol == "HTTPS" && var.certificate_arn == null)
    error_message = "HTTPS 는 CERT(SSL/TSL) 인증서 필수입니다."
  }
}

# ============================================================================
# 옵션 대상그룹
# ============================================================================


variable "target_group_arn" {
  description = "타겟그룹 arn. forward 선택시 필수."
  type = string
  default = null
  validation {
    condition =  !(var.routing_action == "forward" && var.target_group_arn == null)
    error_message = "Only forward, redirect, fixed-response"
  }
}

# ============================================================================
# 옵션 리다이렉션
# ============================================================================
variable "redirect" {
    description = "리다이렉션 설정. 디폴트 https 전체 url 리다이렉션"
    type = object({
        port = optional(string, "443")
        protocol = optional(string, "HTTPS")
        host = optional(string, "#{host}")
        path = optional(string, "/#{path}")
        query = optional(string, "/#{query}")
        status_code = optional(string, "HTTP_301")
    })
    default = {}
    nullable = true
}

# ============================================================================
# 옵션 고정 응답
# ============================================================================
variable "fixed_response" {
    description = "고정응답반환 트러블슈킹및 네트워크트랙킹 쉬운 처리를 위한 고정응답 501 디폴트"
    type = object({
        content_type = optional(string, "text/html")
        message_body = optional(string, "501 Target Not Implemented")
        status_code  = optional(string, "501")
    })
    default = {}
    nullable = true
}