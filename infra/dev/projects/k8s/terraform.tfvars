# ============================================================================
# Project Configuration
# ============================================================================
aws_region         = "ap-northeast-2"
environment        = "dev"
project_name       = "cms"
kubernetes_version = "1.34"

# ============================================================================
# Network Configuration
# ============================================================================
vpc_id = "vpc-276cc74c"
subnet_ids = [
  "subnet-004e0154a4a14df38", # ap-northeast-2a: 172.16.32.0/20
  "subnet-09fe8fd57f9e1780a", # ap-northeast-2b: 172.16.48.0/20
  "subnet-0d3f54f400c8b059a", # ap-northeast-2c: 172.16.64.0/20
]
service_ipv4_cidr = "10.200.0.0/16" # Note: aiagent uses 10.100.0.0/16

# ============================================================================
# Node Group Configuration
# ============================================================================
node_instance_types = ["t3.large"]
node_desired_size   = 2
node_min_size       = 1
node_max_size       = 3
node_disk_size      = 30
