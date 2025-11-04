variable "name" {
  description = "Name of the target group"
  type        = string
}

variable "port" {
  description = "Port on which targets receive traffic"
  type        = number
}

variable "protocol" {
  description = "Protocol to use for routing traffic to the targets"
  type        = string
  default     = "HTTP"
}

variable "vpc_id" {
  description = "VPC ID where the target group will be created"
  type        = string
}

variable "target_type" {
  description = "Type of target (instance, ip, lambda, alb)"
  type        = string
  default     = "ip"
}

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
  default = {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

variable "deregistration_delay" {
  description = "Amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused"
  type        = number
  default     = 300
}

variable "tags" {
  description = "A map of tags to add to the target group"
  type        = map(string)
  default     = {}
}
