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
variable "node_instance_types" {
  description = "EC2 instance types for node group"
  type        = list(string)
  default     = ["t3.large"]
}

variable "node_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 3
}

variable "node_disk_size" {
  description = "Node disk size in GB"
  type        = number
  default     = 30
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

