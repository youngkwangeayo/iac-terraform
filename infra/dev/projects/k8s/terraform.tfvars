# ============================================================================
# Project Configuration
# ============================================================================
aws_region         = "ap-northeast-2"
environment        = "prod"
project_name       = "cms"
kubernetes_version = "1.34"

# ============================================================================
# Network Configuration
# ============================================================================
vpc_id = "vpc******c955"
subnet_ids = [
  "subnet-0e2*******0**ec3", # ap-northeast-2a: 172.16.32.0/20
  "subnet-0016*******f67939", # ap-northeast-2b: 172.16.48.0/20
  "subnet-0ff**********d75b", # ap-northeast-2c: 172.16.64.0/20
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
