
# ============================================================================
# Common Naming and Tags Module
# ============================================================================
module "common" {
  source = "../../../modules/common"

  environment  = var.environment
  project_name = var.project_name

  additional_tags = var.additional_tags
}