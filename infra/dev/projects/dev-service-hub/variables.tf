# ============================================================================
# Project Info
# ============================================================================
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Environment (dev, stg, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "additional_tags" {
  description = "추가 태그"
  type        = map(string)
  default     = {}
}


# ============================================================================
# EKS Cluster Configuration
# ============================================================================
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

# ============================================================================
# Network Configuration
# ============================================================================
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "K8s subnet IDs (at least 2 AZs required)"
  type        = list(string)
  default = [
     # ap-northeast-2a
     # ap-northeast-2b
     # ap-northeast-2c
  ]
}

variable "service_ipv4_cidr" {
  description = "Kubernetes service CIDR (must not conflict with VPC CIDR)"
  type        = string
  default     = "10.200.0.0/16" # aiagent uses 10.100.0.0/16
}

# ============================================================================
# Node Group Configuration
# ============================================================================
variable "node_groups" {
  description = "서비스별 노드 그룹 설정 (signage, cms, aiagent)"
  type = map(object({
    instance_types = list(string)
    desired_size   = number
    min_size       = number
    max_size       = number
    disk_size      = number
  }))
  default = {}
}

# ============================================================================
# Route53 Configuration
# ============================================================================
variable "route53_records" {
  description = "Route53 CNAME records to create (여러 도메인/존 지원)"
  type = list(object({
    zone_id = string
    name    = string
    records = list(string)
  }))
  default = []
}

