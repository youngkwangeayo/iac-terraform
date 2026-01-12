
# ============================================================================
# 프로젝트 정보
# ============================================================================
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "service_name" {
  description = "service_name name"
  type        = string
  default = null
}

variable "environment" {
  description = "Environment (dev, stg, prod)"
  type        = string
  nullable    = false
  validation {
    condition     = contains(["dev", "stg", "prod"], var.environment)
    error_message = "dev, stg, prod 중 택1을 꼭 해주세요."
  }
}




# ============================================================================
# 네트워크 정보
# ============================================================================
variable "use_k8s" {
  description = "k8s용 서브넷 사용여부"
  type = bool
  default = false
}

variable "primary_vpc_name" {
  description = "Name tag of the existing VPC to add secondary CIDR"
  type        = string
}