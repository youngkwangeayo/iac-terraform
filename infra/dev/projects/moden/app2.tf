# ============================================================================
# app2 솔루션
# ============================================================================

# 공통 네이밍 및 태그
module "common_app2" {
  source = "../../../modules/common"

  environment  = var.environment
  project_name = var.project_name
  service_name = "app2"
}

# ECR Repository
module "ecr_app2" {
  source = "../../../modules/ecr"

  repository_name      = module.common_app2.common_name
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true

  force_delete = true
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 7 days of untagged images"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last 10 tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v", "dev", "prod"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = module.common_app2.common_tags
}

# Route53 DNS Record
module "route53_record_app2" {
  source = "../../../modules/route53-record"

  zone_id = var.route53_zone_id
  name    = var.app2_host_header
  type    = "CNAME"
  ttl     = 300
  records = [data.terraform_remote_state.elb.outputs.alb_dns_name]
}

# Target Group
module "target_group_app2" {
  source = "../../../modules/load-balancer/target-group"

  name = module.common_app2.common_name

  port        = var.app2_target_port
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  target_type = "instance"

  target = [
    {
      target_id = data.aws_instance.signage.id
      port      = var.app2_target_port
    }
  ]

  health_check = {
    enabled             = true
    path                = var.app2_health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = module.common_app2.common_tags
}

# ALB Listener Rule (HTTPS 443)
module "listener_rule_app2" {
  source = "../../../modules/load-balancer/rule"

  name         = module.common_app2.common_name
  listener_arn = data.terraform_remote_state.elb.outputs.https_listener_arn
  priority     = var.app2_listener_rule_priority

  host_header_values = var.app2_host_header
  routing_action     = "forward"
  target_group_arn   = module.target_group_app2.target_group_arn
}
