variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "alb_name" {
  description = "Name of the existing Application Load Balancer (dev-cms-elb for dev environment)"
  type        = string
  default     = "dev-cms-elb"
}

variable "create_target_group" {
  description = "Whether to create a target group"
  type        = bool
  default     = false
}

variable "target_group_config" {
  description = "Target group configuration"
  type = object({
    name        = string
    port        = number
    protocol    = string
    target_type = string
    health_check = object({
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
  })
  default = null
}

variable "listener_rule_priority" {
  description = "Priority for the listener rule (1-50000)"
  type        = number
  default     = 100
}

variable "listener_rule_conditions" {
  description = "Conditions for the listener rule"
  type = list(object({
    path_pattern = optional(list(string))
    host_header  = optional(list(string))
  }))
  default = []
}
