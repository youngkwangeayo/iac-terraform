# ============================================================================
# Project Configuration
# ============================================================================
aws_region         = "ap-northeast-2"
environment        = "prod"
project_name       = "mgmt-hub-cluster"
kubernetes_version = "1.35"

additional_tags = {
  OwnerTeam = "devops"
}

# ============================================================================
# Network Configuration
# ============================================================================
vpc_id = "vpc******dcc955"
subnet_ids = [
  "subnet-0e2******0b960ec3", # ap-northeast-2a: 172.16.32.0/20
  "subnet-00168******8f67939", # ap-northeast-2b: 172.16.48.0/20
  "subnet-0******75b", # ap-northeast-2c: 172.16.64.0/20
]
service_ipv4_cidr = "10.200.0.0/16" # Note: aiagent uses 10.100.0.0/16

# ============================================================================
# Node Group Configuration
# ============================================================================
node_instance_types = ["t3.large"]
node_desired_size   = 2
node_min_size       = 1
node_max_size       = 3
node_disk_size      = 64

# ============================================================================
# Route53 Configuration
# ============================================================================
route53_records = [
  {
    zone_id = "Z07503******764"          # Route53 Hosted Zone ID
    name    = "mgmt-hub.******.co.kr"      # 레코드 이름
    records = ["k8s-prodmgmthub-******-2.elb.amazonaws.com"] # ALB/NLB DNS
  }
]



