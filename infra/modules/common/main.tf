# 네이밍 규칙: {aws-service}-{environment}-{solution}[-{component}]
locals {
  # 기본 name prefix: {environment}-{project_name}
  base_prefix = "${var.environment}-${var.project_name}"

  # AWS 서비스 포함 prefix: {aws_service}-{environment}-{project_name}
  service_prefix = var.aws_service != "" ? "${var.aws_service}-${var.environment}-${var.project_name}" : local.base_prefix

  # 컴포넌트 포함 전체 name: {aws_service}-{environment}-{project_name}-{component}
  full_name = var.component != "" ? "${local.service_prefix}-${var.component}" : local.service_prefix

  # 공통 태그
  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    },
    var.additional_tags
  )
}
