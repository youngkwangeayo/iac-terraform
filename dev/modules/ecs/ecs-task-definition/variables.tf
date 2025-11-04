variable "family" {
  description = "A unique name for your task definition"
  type        = string
}

variable "cpu" {
  description = "The number of cpu units used by the task"
  type        = string
  default     = "512"
}

variable "memory" {
  description = "The amount (in MiB) of memory used by the task"
  type        = string
  default     = "1024"
}

variable "network_mode" {
  description = "The Docker networking mode to use for the containers in the task"
  type        = string
  default     = "awsvpc"
}

variable "requires_compatibilities" {
  description = "A set of launch types required by the task"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "task_role_arn" {
  description = "The ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services"
  type        = string
}

variable "execution_role_arn" {
  description = "The ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume"
  type        = string
}

variable "container_definitions" {
  description = "A list of container definitions in JSON format"
  type        = string
}

variable "runtime_platform" {
  description = "Configuration block for runtime_platform"
  type = object({
    cpu_architecture        = optional(string, "X86_64")
    operating_system_family = optional(string, "LINUX")
  })
  default = {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
}

variable "tags" {
  description = "A map of tags to add to the task definition"
  type        = map(string)
  default     = {}
}
