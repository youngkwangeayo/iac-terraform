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
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "cms"
}

# ============================================================================
# EKS Cluster Configuration
# ============================================================================
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.33"
}

# ============================================================================
# Network Configuration
# ============================================================================
variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-276cc74c"
}

variable "subnet_ids" {
  description = "K8s subnet IDs (at least 2 AZs required)"
  type        = list(string)
  default = [
    "subnet-004e0154a4a14df38", # ap-northeast-2a
    "subnet-09fe8fd57f9e1780a", # ap-northeast-2b
    "subnet-0d3f54f400c8b059a", # ap-northeast-2c
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
