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
# 리스너 룰 정보.
# ============================================================================

variable "listener_arn" {
    description = "The ARN of the load balancer listener."
    type        = string
}

variable "priority" {
    description = "The priority of the listener rule."
    type        = number
}

variable "host_header_values" {
    description = "The host header values for the listener rule condition."
    type        = string
}


variable "routing_action" {
  description = "라우팅 액션.  [대상그룹,리다이렉션,고정반환] 중 택1"
  type = string
  validation {
    condition = contains(["forward","redirect","fixed-response"], var.routing_action)
    error_message = "Only forward, redirect, fixed-response"
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