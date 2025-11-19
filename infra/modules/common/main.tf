# 네이밍 규칙: {resouce}-{environment}-{solutionName}[-{serviceName}]
locals {
  
  common_name = join( "-", compact( [ var.environment, var.project_name, var.service_name ] ) )

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
