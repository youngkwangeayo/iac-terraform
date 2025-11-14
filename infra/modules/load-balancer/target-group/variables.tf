
# ============================================================================
# 프로젝트 정보
# ============================================================================

variable "name" {
  description = "targetGruopName Import from module 'common' and use it"
  type = string
}


variable "tags" {
  description = "Import from module 'common' and use it"
  type        = map(string)
  default     = {}
}


# ============================================================================
# 타겟유형
# ============================================================================
variable "target_type" {
  description = "Select target type."
  type = string
  default = null
  validation {
    condition = var.target_type==null || contains(["ip", "lambda", "alb","instance"], var.target_type)
    error_message = "Only null,ip,lambda,alb. Ps instances type is null"
  }
}



# ============================================================================
# 트레픽 설정
# ============================================================================

variable "port" {
  description = "Port on which targets receive traffic"
  type        = number
  nullable = true
}

variable "protocol" {
  description = "Protocol to use for routing traffic to the targets"
  type        = string
  default     = "HTTP"
}

variable "vpc_id" {
  description = "Select the VPC that contains the Application Load Balancer you want to include in the target group."
  type = string
  default = null
  validation {
    condition = !(var.target_type == "lambda" && var.vpc_id != null)
    error_message = "vpc_id must be null when target_type is lambda"
  }
}

# ============================================================================
# 헬스체크
# ============================================================================

variable "health_check" {
  description = "Health check configuration"
  type = object({
    enabled             = optional(bool, true)
    path                = optional(string, "/")
    port                = optional(string, "traffic-port")
    protocol            = optional(string, "HTTP")
    healthy_threshold   = optional(number, 3)
    unhealthy_threshold = optional(number, 3)
    timeout             = optional(number, 5)
    interval            = optional(number, 30)
    matcher             = optional(string, "200")
  })
  default = null
}

