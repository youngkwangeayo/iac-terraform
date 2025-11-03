# modules/ecs/cluster/variables.tf

variable "cluster_name" {
  type        = string
  description = "Name of the ECS cluster (without prefix)"
}

variable "project" {
  type        = string
  description = "Project name prefix"
}

variable "env" {
  type        = string
  description = "Environment (dev, stage, prod)"
}

variable "capacity_providers" {
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
  description = "List of capacity providers (FARGATE, FARGATE_SPOT)"
}

variable "default_capacity_provider_strategy" {
  type = list(object({
    capacity_provider = string
    weight            = optional(number)
    base              = optional(number)
  }))
  default     = []
  description = "Default capacity provider strategy for the cluster"
}

variable "extra_tags" {
  type        = map(string)
  default     = {}
  description = "Additional custom tags"
}
