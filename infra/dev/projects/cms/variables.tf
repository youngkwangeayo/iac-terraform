variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "cms"
}

variable "environment" {
  description = "Environment (dev, prod)"
  type        = string
  default     = "dev"
}

variable "container_port" {
  description = "Container port for the application"
  type        = number
  default     = 3827
}

variable "container_image" {
  description = "Container image URI (will be constructed from ECR)"
  type        = string
  default     = ""
}

variable "container_image_tag" {
  description = "Container image tag"
  type        = string
  default     = "latest"
}

variable "task_cpu" {
  description = "Task CPU units"
  type        = string
  default     = "512"
}

variable "task_memory" {
  description = "Task memory in MiB"
  type        = string
  default     = "1024"
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/api/ping"
}

variable "alb_listener_rule_priority" {
  description = "Priority for ALB listener rule"
  type        = number
  default     = 100
}

variable "alb_listener_rule_path_pattern" {
  description = "Path pattern for ALB listener rule"
  type        = list(string)
  default     = ["/cms/*"]
}
