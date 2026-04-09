# ============================================================================
# Project Configuration
# ============================================================================
aws_region         = "ap-northeast-2"
environment        = "dev"
project_name       = "service-hub"
kubernetes_version = "1.35"

additional_tags = {
  OwnerTeam = "dev-service-hub"
}

# ============================================================================
# Network Configuration
# ============================================================================
vpc_id = "vpc-276cc74c"
subnet_ids = [
  "subn*******8", # ap-northeast-2a: 172.16.32.0/20
  "subn*******0a", # ap-northeast-2b: 172.16.48.0/20
  "subn*******059a", # ap-northeast-2c: 172.16.64.0/20
]
service_ipv4_cidr = "10.200.0.0/16"

# ============================================================================
# Node Group Configuration (서비스별 독립 노드그룹)
# ============================================================================
node_groups = {
  infra = {
    instance_types = ["t3.large"]
    desired_size   = 1
    min_size       = 1
    max_size       = 2
    disk_size      = 64
  }
  signage = {
    instance_types = ["t3.large"]
    desired_size   = 1
    min_size       = 1
    max_size       = 2
    disk_size      = 64
  }
  cms = {
    instance_types = ["t3.large"]
    desired_size   = 1
    min_size       = 1
    max_size       = 2
    disk_size      = 64
  }
  aiagent = {
    instance_types = ["t3.large"]
    desired_size   = 1
    min_size       = 1
    max_size       = 2
    disk_size      = 64
  }
}

# ============================================================================
# Route53 Configuration
# ============================================================================
route53_records = [
  {
    zone_id = "Z0*******764"                    # Route53 Hosted Zone ID
    name    = "grafan*******o.kr"    # 레코드 이름
    records = ["tmp-alb.nextpay.co.kr"] # terraform apply 후 ALB DNS로 업데이트 필요
  }
]
