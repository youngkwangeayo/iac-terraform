# ============================================================================
# Project Configuration
# ============================================================================
aws_region         = "ap-northeast-2"
environment        = "dev"
project_name       = "signage"
kubernetes_version = "1.35"

additional_tags = {
  OwnerTeam = "signage"
}

# ============================================================================
# Network Configuration
# ============================================================================
vpc_id = "vpc-276cc74c"
subnet_ids = [
  "subnet-0*******38", # ap-northeast-2a: 172.16.32.0/20
  "subnet-0*******780a", # ap-northeast-2b: 172.16.48.0/20
  "subnet-0d3*******59a", # ap-northeast-2c: 172.16.64.0/20
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
    zone_id = "Z075035514XCM0YECN764"          # Route53 Hosted Zone ID
    name    = "gr*******co.kr"      # 레코드 이름
    records = ["k8s-*******aws.com"] # ALB/NLB DNS
  }
]



