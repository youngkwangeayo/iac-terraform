# ============================================================================
# Project Configuration
# ============================================================================
aws_region         = "ap-northeast-2"
environment        = "prod"
project_name       = "cms"

additional_tags = {
  OwnerTeam = "cms"
}


# ============================================================================
# Route53 Configuration
# ============================================================================
route53_records = [
  {
    alias   = "cms"                                                                  # output 참조 키
    zone_id = "Z07******N764"                                                   # Route53 Hosted Zone ID
    name    = "serv***ay.co.kr"                                       # 레코드 이름
    records = ["k8s-prodcms-62*****aws.com"] # ALB/NLB DNS
  },
  {
    alias   = "coffeezip-cms"                                                                  # output 참조 키
    zone_id = "Z07******N764"                                                   # Route53 Hosted Zone ID
    name    = "cof***tay.co.kr"                                       # 레코드 이름
    records = ["k8s-prodcms-62*****aws.com"] # ALB/NLB DNS
  },
  {
    alias   = "grafana"                                                                  # output 참조 키
    zone_id = "Z07******N764"                                                   # Route53 Hosted Zone ID
    name    = "grafa***tpay.co.kr"                                       # 레코드 이름
    records = ["k8s-prodcms-62*****aws.com"] # ALB/NLB DNS
  }
]



