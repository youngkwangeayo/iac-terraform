variable "name" {
  description = "Name of the ECS service"
  type        = string
}

variable "cluster_id" {
  description = "ARN of the ECS cluster"
  type        = string
}

variable "task_definition_arn" {
  description = "ARN of the task definition"
  type        = string
}

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running"
  type        = number
  default     = 1
}

variable "launch_type" {
  description = "Launch type on which to run your service (EC2, FARGATE, EXTERNAL)"
  type        = string
  default     = null
}

variable "capacity_provider_strategy" {
  description = "Capacity provider strategies to use for the service"
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = number
  }))
  default = []
}

variable "platform_version" {
  description = "Platform version on which to run your service (only applicable for FARGATE)"
  type        = string
  default     = "LATEST"
}

variable "scheduling_strategy" {
  description = "Scheduling strategy to use for the service (REPLICA, DAEMON)"
  type        = string
  default     = "REPLICA"
}

variable "network_configuration" {
  description = "Network configuration for the service"
  type = object({
    subnets          = list(string)
    security_groups  = list(string)
    assign_public_ip = bool
  })
}

variable "load_balancer" {
  description = "Load balancer configuration"
  type = object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  })
  default = null
}

variable "deployment_strategy" {
  description = "베포옵션전략선택"
  type = string
  validation {
    condition = contains(["ROLLING", "BLUE_GREEN"], var.deployment_strategy)
    error_message = "ROLLING, BLUE_GREEN 중 택 1"
  } 
  default = "ROLLING"
}

variable "blue_green_deployment" {
  description = "use to blue_green_deployment"
  type = object({
    alternate_target_group_arn = string
    production_listener_rule = string
    role_arn = string
  })

  default = null
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks"
  type        = number
  default     = 90
}

variable "deployment_configuration" {
  description = "Deployment configuration"
  type = object({
    maximum_percent         = number
    minimum_healthy_percent = number
    deployment_circuit_breaker = object({
      enable   = bool
      rollback = bool
    })
  })
  default = {
    maximum_percent         = 200
    minimum_healthy_percent = 100
    deployment_circuit_breaker = {
      enable   = true
      rollback = true
    }
  }
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for the service"
  type        = bool
  default     = true
}

variable "enable_ecs_managed_tags" {
  description = "Enable Amazon ECS managed tags for the tasks"
  type        = bool
  default     = true
}

variable "propagate_tags" {
  description = "Specifies whether to propagate tags from the task definition or service to tasks (TASK_DEFINITION, SERVICE, NONE)"
  type        = string
  default     = "NONE"
}

variable "tags" {
  description = "A map of tags to add to the service"
  type        = map(string)
  default     = {}
}
