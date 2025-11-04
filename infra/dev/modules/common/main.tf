# 네이밍 규칙: {environment}-{project_name}[-{aws_service}][-{component}]
locals {
  # 기본 name prefix
  base_prefix = "${var.environment}-${var.project_name}"

  # AWS 서비스 포함 prefix (옵션)
  service_prefix = var.aws_service != "" ? "${var.environment}-${var.aws_service}-${var.project_name}" : local.base_prefix

  # 컴포넌트 포함 전체 name (옵션)
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
