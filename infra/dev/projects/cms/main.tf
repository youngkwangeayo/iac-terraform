# ============================================================================
# Remote State 참조 - 공통 인프라 리소스
# ============================================================================

# Network 정보 참조 (dev-vpc)
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "nextpay-terraform-state"
    key    = "dev/resources/network/nextpay/terraform.tfstate"
    region = var.aws_region
  }
}

# ELB 정보 참조 (nextpay ELB)
data "terraform_remote_state" "elb" {
  backend = "s3"
  config = {
    bucket = "nextpay-terraform-state"
    key    = "dev/resources/elb/nextpay/terraform.tfstate"
    region = var.aws_region
  }
}

# IAM Role 정보 참조 (ECS Roles)
data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "nextpay-terraform-state"
    key    = "dev/resources/iam/ecs-roles/terraform.tfstate"
    region = var.aws_region
  }
}

# ============================================================================
# 공통 네이밍 및 태그 모듈
# ============================================================================

module "common" {
  source = "../../../modules/common"

  environment  = var.environment
  project_name = var.project_name
}


# 로컬 변수 (모듈에서 가져온 값 사용)
locals {
  name_prefix = module.common.name_prefix
  common_tags = module.common.common_tags

}

# ============================================================================
# ECR Repository (프로젝트 전용)
# ============================================================================

module "ecr" {
  source = "../../../modules/ecr"

  repository_name      = "ecr-${local.name_prefix}"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true

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

  tags = local.common_tags
}

# ============================================================================
# Security Group (프로젝트 전용)
# ============================================================================

module "ecs_security_group" {
  source = "../../../modules/security-group"

  name        = "${local.name_prefix}-ecs-sg"
  description = "Security group for CMS ECS tasks"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = [
    {
      from_port       = var.container_port
      to_port         = var.container_port
      protocol        = "tcp"
      security_groups = [var.allowed_security_group_ids]
      description     = "Allow traffic from specified SG"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]

  tags = local.common_tags
}

# ============================================================================
# Target Group (프로젝트 전용)
# ============================================================================

module "target_group" {
  source = "../../../modules/target-group"

  name        = "tg-${local.name_prefix}"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  target_type = "ip"

  health_check = {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = local.common_tags
}

# ============================================================================
# ALB Listener Rule (HTTPS)
# ============================================================================

resource "aws_lb_listener_rule" "https" {
  listener_arn = data.terraform_remote_state.elb.outputs.https_listener_arn
  priority     = var.alb_listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = module.target_group.target_group_arn
  }

  condition {
    host_header {
      values = [var.alb_listener_rule_host_header]
    }
  }

  tags = local.common_tags
}

# ============================================================================
# Route53 DNS Record
# ============================================================================

module "route53_record" {
  source = "../../../modules/route53-record"

  zone_id = var.route53_zone_id
  name    = var.alb_listener_rule_host_header
  type    = "CNAME"
  ttl     = 300
  records = [data.terraform_remote_state.elb.outputs.alb_dns_name]
}

# ============================================================================
# ECS Cluster (프로젝트 전용)
# ============================================================================

module "ecs_cluster" {
  source = "../../../modules/ecs/ecs-cluster"

  cluster_name        = "cluster-${local.name_prefix}"
  capacity_providers  = ["FARGATE", "FARGATE_SPOT"]
  container_insights  = true

  tags = local.common_tags
}

# ============================================================================
# CloudWatch Log Group
# ============================================================================

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${local.name_prefix}"
  retention_in_days = 7

  tags = local.common_tags
}

# ============================================================================
# ECS Task Definition
# ============================================================================

module "ecs_task_definition" {
  source = "../../../modules/ecs/ecs-task-definition"

  family                   = "task-${local.name_prefix}"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = data.terraform_remote_state.iam.outputs.ecs_task_role_arn
  execution_role_arn       = data.terraform_remote_state.iam.outputs.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = var.project_name
      image     = var.container_image != null ? "${var.container_image}:${var.container_image_tag}" : "${module.ecr.repository_url}:${var.container_image_tag}"
      cpu       = 0
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
          name          = "${var.project_name}-port"
          appProtocol   = "http"
        }
      ]

      environment = [
        for k, v in var.environment_vars : {
          name  = k
          value = v
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}${var.health_check_path} || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 2
        startPeriod = 90
      }

      startTimeout = 90
      stopTimeout  = 120
    }
  ])

  runtime_platform = {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  tags = local.common_tags
}

# ============================================================================
# ECS Service
# ============================================================================

module "ecs_service" {
  source = "../../../modules/ecs/ecs-service"

  name                = "service-${local.name_prefix}"
  cluster_id          = module.ecs_cluster.cluster_arn
  task_definition_arn = module.ecs_task_definition.task_definition_arn
  desired_count       = var.desired_count
  platform_version    = "LATEST"
  scheduling_strategy = "REPLICA"

  capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 0
    }
  ]

  network_configuration = {
    subnets          = data.terraform_remote_state.network.outputs.private_subnet_ids
    security_groups  = [module.ecs_security_group.security_group_id, var.allowed_security_group_ids]
    assign_public_ip = true
  }

  load_balancer = {
    target_group_arn = module.target_group.target_group_arn
    container_name   = var.project_name
    container_port   = var.container_port
  }

  health_check_grace_period_seconds = 90

  deployment_configuration = {
    maximum_percent         = 200
    minimum_healthy_percent = 100
    deployment_circuit_breaker = {
      enable   = true
      rollback = true
    }
  }

  enable_execute_command  = true
  enable_ecs_managed_tags = true
  propagate_tags          = "NONE"

  tags = local.common_tags
}

# ============================================================================
# ECS Autoscaling
# ============================================================================

module "ecs_autoscaling" {
  source = "../../../modules/ecs/ecs-autoscaling"

  cluster_name = module.ecs_cluster.cluster_name
  service_name = module.ecs_service.service_name

  min_capacity = var.autoscaling_min_capacity
  max_capacity = var.autoscaling_max_capacity

  policy_name            = "autoScale-${local.name_prefix}"
  predefined_metric_type = var.autoscaling_metric_type
  target_value           = var.autoscaling_target_value
  scale_in_cooldown      = var.autoscaling_scale_in_cooldown
  scale_out_cooldown     = var.autoscaling_scale_out_cooldown
  disable_scale_in       = false
}
