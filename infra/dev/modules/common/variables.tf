variable "environment" {
  description = "Environment name (dev, prod, staging)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "aws_service" {
  description = "AWS service name (optional, for resource naming)"
  type        = string
  default     = ""
}

variable "component" {
  description = "Component name (optional, for resource naming)"
  type        = string
  default     = ""
}

variable "additional_tags" {
  description = "Additional tags to merge with common tags"
  type        = map(string)
  default     = {}
}
