# ============================================================================
# Project Configuration
# ============================================================================
aws_region         = "ap-northeast-2"
environment        = "prod"
project_name       = "signage"
kubernetes_version = "1.35"

additional_tags = {
  OwnerTeam = "signage"
}

# ============================================================================
# Network Configuration
# ============================================================================
vpc_id = "vpc-******edcc955"
subnet_ids = [
  "subnet-0e2******ec3", # ap-northeast-2a: 172.16.32.0/20
  "subnet-001******67939", # ap-northeast-2b: 172.16.48.0/20
  "subnet-0ff******d75b", # ap-northeast-2c: 172.16.64.0/20
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
    zone_id = "Z0750******"          # Route53 Hosted Zone ID
    name    = "g******y.co.kr"      # 레코드 이름
    records = ["k8s-******.com"] # ALB/NLB DNS
  },
  {
    zone_id = "Z0750******"          # Route53 Hosted Zone ID
    name    = "sm.nextpay.co.kr"      # 레코드 이름
    records = ["k8s-******.com"] # ALB/NLB DNS
  },
  {
    zone_id = "Z0750******"          # Route53 Hosted Zone ID
    name    = "sm-cms.nextpay.co.kr"      # 레코드 이름
    records = ["k8s-******.com"] # ALB/NLB DNS
  },
  {
    zone_id = "Z0750******"          # Route53 Hosted Zone ID
    name    = "sm-api.nextpay.co.kr"      # 레코드 이름
    records = ["k8s-******.com"] # ALB/NLB DNS
  }
]



