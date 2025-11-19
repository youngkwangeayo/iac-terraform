variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "capacity_providers" {
  description = "List of capacity providers to associate with the cluster"
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "default_capacity_provider_strategy" {
  description = "Default capacity provider strategy for the cluster"
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = number
  }))
  default = []
}

variable "container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = string

  validation {
    condition = contains(["enhanced", "enabled", "disabled"], var.container_insights)
    error_message = "모니터링 여부 사용 가능한 값은 enhanced, enabled, disabled 택1"
  }
}

variable "tags" {
  description = "A map of tags to add to the cluster"
  type        = map(string)
  default     = {}
}
