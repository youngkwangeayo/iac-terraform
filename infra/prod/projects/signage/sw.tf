# # ============================================================================
# # sw 솔루션
# # ============================================================================

# # 공통 네이밍 및 태그
# module "common_sw" {
#   source = "../../../modules/common"

#   environment  = var.environment
#   project_name = var.project_name
#   service_name = "sw"
#   additional_tags = var.additional_tags
# }

# # ECR Repository
# module "ecr_sw" {
#   source = "../../../modules/ecr"

#   repository_name      = module.common_sw.common_name
#   image_tag_mutability = "MUTABLE"
#   scan_on_push         = true

#   force_delete = true
#   lifecycle_policy = jsonencode({
#     rules = [
#       {
#         rulePriority = 1
#         description  = "Keep last 7 days of untagged images"
#         selection = {
#           tagStatus   = "untagged"
#           countType   = "sinceImagePushed"
#           countUnit   = "days"
#           countNumber = 7
#         }
#         action = {
#           type = "expire"
#         }
#       },
#       {
#         rulePriority = 2
#         description  = "Keep last 10 tagged images"
#         selection = {
#           tagStatus     = "tagged"
#           tagPrefixList = ["v", "dev", "prod"]
#           countType     = "imageCountMoreThan"
#           countNumber   = 10
#         }
#         action = {
#           type = "expire"
#         }
#       }
#     ]
#   })

#   tags = module.common_sw.common_tags
# }

# # # # Route53 DNS Record
# # module "route53_record_sw" {
# #   source = "../../../modules/route53-record"

# #   zone_id = var.route53_zone_id
# #   name    = var.sw_host_header
# #   type    = "CNAME"
# #   ttl     = 300
# #   records = ["tmp-alb.nextpay.co.kr"]
# # }
