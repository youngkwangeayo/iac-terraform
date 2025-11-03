# modules/ecs/service/variables.tf

variable "service_name" {
  type        = string
  description = "Name of the ECS service (without prefix)"
}

variable "project" {
  type        = string
  description = "Project name prefix"
}

variable "env" {
  type        = string
  description = "Environment (dev, stage, prod)"
}

variable "cluster_id" {
  type        = string
  description = "ECS cluster ID"
}

variable "task_definition_arn" {
  type        = string
  description = "Task definition ARN"
}

variable "desired_count" {
  type        = number
  default     = 1
  description = "Desired number of tasks"
}

variable "launch_type" {
  type        = string
  default     = ""
  description = "Launch type (FARGATE, EC2, EXTERNAL). Leave empty if using capacity_provider_strategy"
}

variable "platform_version" {
  type        = string
  default     = "LATEST"
  description = "Platform version (LATEST, 1.4.0, etc.)"
}

variable "capacity_provider_strategy" {
  type = list(object({
    capacity_provider = string
    weight            = optional(number)
    base              = optional(number)
  }))
  default     = []
  description = "Capacity provider strategy for the service"
}

variable "subnets" {
  type        = list(string)
  description = "List of subnet IDs for the service"
}

variable "security_groups" {
  type        = list(string)
  description = "List of security group IDs for the service"
}

variable "assign_public_ip" {
  type        = bool
  default     = true
  description = "Whether to assign a public IP address"
}

variable "load_balancers" {
  type = list(object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  }))
  default     = []
  description = "Load balancer configurations"
}

variable "deployment_maximum_percent" {
  type        = number
  default     = 200
  description = "Maximum percentage of tasks during deployment"
}

variable "deployment_minimum_healthy_percent" {
  type        = number
  default     = 100
  description = "Minimum healthy percentage during deployment"
}

variable "enable_circuit_breaker" {
  type        = bool
  default     = true
  description = "Enable deployment circuit breaker"
}

variable "enable_rollback" {
  type        = bool
  default     = true
  description = "Enable automatic rollback on deployment failure"
}

variable "health_check_grace_period_seconds" {
  type        = number
  default     = 90
  description = "Grace period for health checks in seconds"
}

variable "scheduling_strategy" {
  type        = string
  default     = "REPLICA"
  description = "Scheduling strategy (REPLICA, DAEMON)"
}

variable "enable_execute_command" {
  type        = bool
  default     = true
  description = "Enable ECS Exec for debugging"
}

variable "enable_ecs_managed_tags" {
  type        = bool
  default     = true
  description = "Enable ECS managed tags"
}

variable "propagate_tags" {
  type        = string
  default     = "NONE"
  description = "Propagate tags from (NONE, SERVICE, TASK_DEFINITION)"
}

variable "extra_tags" {
  type        = map(string)
  default     = {}
  description = "Additional custom tags"
}
