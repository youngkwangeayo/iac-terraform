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

variable "service_name" {
  description = "service_name name"
  type        = string
  default = null
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
# 네트워크 설정
# ============================================================================
variable "alb_listener_rule_priority" {
  description = "Priority for ALB listener rule"
  type        = number
}

variable "alb_listener_rule_host_header" {
  description = "Host header for ALB listener rule"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 Hosted Zone ID for nextpay.co.kr"
  type        = string
  default     = "Z075035514XCM0YECN764"
}

variable "generate_route53_record" {
  description = "라우트53 레코드 생성 (도메인 새로 생성) 여부"
  type        = bool
  default     = true
}

# ============================================================================
# App 설정
# ============================================================================
variable "container_port" {
  description = "Container port for the application"
  type        = number
  nullable = false
}

variable "container_image_url" {
  description = "Container image URI (will be constructed from ECR)"
  type        = string
  default     = null
}

variable "container_image_tag" {
  description = "Container image tag"
  type        = string
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "allowed_security_group_ids" {
  # sg-0d856c4c37acc59c5
  description = "기존에 생성된 sg id"
  type        = string
  default = null
}

# ============================================================================
# 컴퓨팅 설정
# ============================================================================
variable "task_cpu" {
  description = "Task CPU units"
  type        = string
}

variable "task_memory" {
  description = "Task memory in MiB"
  type        = string
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
}

# ============================================================================
# 오토스케일링 설정
# ============================================================================
variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks for autoscaling"
  type        = number
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks for autoscaling"
  type        = number
}

variable "autoscaling_metric_type" {
  description = "Predefined metric type for autoscaling (ECSServiceAverageCPUUtilization, ECSServiceAverageMemoryUtilization)"
  type        = string
  default     = "ECSServiceAverageCPUUtilization"
}

variable "autoscaling_target_value" {
  description = "Target value for the autoscaling metric"
  type        = number
  default     = 70.0
}

variable "autoscaling_scale_in_cooldown" {
  description = "Time between scale in actions in seconds"
  type        = number
  default     = 120
}

variable "autoscaling_scale_out_cooldown" {
  description = "Time between scale out actions in seconds"
  type        = number
  default     = 60
}

# ============================================================================
# 모니터링 설정
# ============================================================================
variable "container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = string
}

# ============================================================================
# 환경변수 설정
# ============================================================================
variable "environment_vars" {
  description = "Environment variables for the container (key-value pairs)"
  type        = map(string)
  default     = {}
}

