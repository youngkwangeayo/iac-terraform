# modules/ecs/task-definition/variables.tf

variable "task_family" {
  type        = string
  description = "Task definition family name (without prefix)"
}

variable "project" {
  type        = string
  description = "Project name prefix"
}

variable "env" {
  type        = string
  description = "Environment (dev, stage, prod)"
}

variable "network_mode" {
  type        = string
  default     = "awsvpc"
  description = "Network mode for the task (awsvpc, bridge, host, none)"
}

variable "requires_compatibilities" {
  type        = list(string)
  default     = ["FARGATE"]
  description = "Launch type requirements (FARGATE, EC2)"
}

variable "cpu" {
  type        = string
  description = "Task CPU units (256, 512, 1024, 2048, 4096)"
}

variable "memory" {
  type        = string
  description = "Task memory in MB (512, 1024, 2048, 4096, 8192)"
}

variable "task_role_arn" {
  type        = string
  description = "IAM role ARN for ECS task"
}

variable "execution_role_arn" {
  type        = string
  description = "IAM role ARN for ECS task execution"
}

variable "operating_system_family" {
  type        = string
  default     = "LINUX"
  description = "Operating system family (LINUX, WINDOWS_SERVER_2019_FULL, WINDOWS_SERVER_2019_CORE)"
}

variable "cpu_architecture" {
  type        = string
  default     = "X86_64"
  description = "CPU architecture (X86_64, ARM64)"
}

variable "container_name" {
  type        = string
  description = "Container name"
}

variable "container_image" {
  type        = string
  description = "Container image URI"
}

variable "container_cpu" {
  type        = number
  default     = 0
  description = "Container CPU units (0 means use task-level CPU)"
}

variable "port_mappings" {
  type = list(object({
    container_port = number
    host_port      = number
    protocol       = optional(string)
    name           = optional(string)
    app_protocol   = optional(string)
  }))
  description = "Port mappings for the container"
}

variable "environment_variables" {
  type        = map(string)
  default     = {}
  description = "Environment variables for the container"
}

variable "aws_region" {
  type        = string
  description = "AWS region for CloudWatch logs"
}

variable "log_group_name" {
  type        = string
  default     = ""
  description = "CloudWatch log group name (auto-generated if empty)"
}

variable "health_check_command" {
  type        = string
  default     = ""
  description = "Health check command (empty to disable)"
}

variable "health_check_interval" {
  type        = number
  default     = 30
  description = "Health check interval in seconds"
}

variable "health_check_timeout" {
  type        = number
  default     = 5
  description = "Health check timeout in seconds"
}

variable "health_check_retries" {
  type        = number
  default     = 2
  description = "Health check retries"
}

variable "health_check_start_period" {
  type        = number
  default     = 90
  description = "Health check start period in seconds"
}

variable "start_timeout" {
  type        = number
  default     = 90
  description = "Container start timeout in seconds"
}

variable "stop_timeout" {
  type        = number
  default     = 120
  description = "Container stop timeout in seconds"
}

variable "extra_tags" {
  type        = map(string)
  default     = {}
  description = "Additional custom tags"
}
