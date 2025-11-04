# modules/ecs/autoscaling/variables.tf

variable "project" {
  type        = string
  description = "Project name prefix"
}

variable "env" {
  type        = string
  description = "Environment (dev, stage, prod)"
}

variable "cluster_name" {
  type        = string
  description = "ECS cluster name"
}

variable "service_name" {
  type        = string
  description = "ECS service name"
}

variable "min_capacity" {
  type        = number
  default     = 1
  description = "Minimum number of tasks"
}

variable "max_capacity" {
  type        = number
  default     = 3
  description = "Maximum number of tasks"
}

variable "enable_cpu_scaling" {
  type        = bool
  default     = true
  description = "Enable CPU-based auto scaling"
}

variable "cpu_target_value" {
  type        = number
  default     = 70
  description = "Target CPU utilization percentage"
}

variable "enable_memory_scaling" {
  type        = bool
  default     = true
  description = "Enable memory-based auto scaling"
}

variable "memory_target_value" {
  type        = number
  default     = 80
  description = "Target memory utilization percentage"
}

variable "enable_alb_request_count_scaling" {
  type        = bool
  default     = false
  description = "Enable ALB request count based auto scaling"
}

variable "alb_request_count_target_value" {
  type        = number
  default     = 1000
  description = "Target request count per target"
}

variable "alb_resource_label" {
  type        = string
  default     = ""
  description = "ALB resource label (format: app/alb-name/xxx/targetgroup/tg-name/yyy)"
}

variable "scale_in_cooldown" {
  type        = number
  default     = 300
  description = "Scale in cooldown period in seconds"
}

variable "scale_out_cooldown" {
  type        = number
  default     = 60
  description = "Scale out cooldown period in seconds"
}
