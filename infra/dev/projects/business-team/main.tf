# ============================================================================
# 공통 네이밍
# ============================================================================

module "common" {
  source = "../../../modules/common"

  environment  = var.environment
  project_name = var.project_name
  service_name = "hr"
}
