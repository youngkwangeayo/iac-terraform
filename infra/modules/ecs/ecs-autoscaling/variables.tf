variable "cluster_name" {
  description = "ECS Cluster name"
  type        = string
}

variable "service_name" {
  description = "ECS Service name"
  type        = string
}

variable "min_capacity" {
  description = "Minimum number of tasks"
  type        = number
}

variable "max_capacity" {
  description = "Maximum number of tasks"
  type        = number
}

variable "policy_name" {
  description = "Autoscaling policy name"
  type        = string
}

variable "target_value" {
  description = "Target value for the metric"
  type        = number
}

variable "predefined_metric_type" {
  description = "Predefined metric type (ECSServiceAverageCPUUtilization, ECSServiceAverageMemoryUtilization)"
  type        = string
}

variable "scale_in_cooldown" {
  description = "Time between scale in actions in seconds"
  type        = number
  default     = 120
}

variable "scale_out_cooldown" {
  description = "Time between scale out actions in seconds"
  type        = number
  default     = 60
}

variable "disable_scale_in" {
  description = "Whether to disable scale-in"
  type        = bool
  default     = false
}
