# ============================================================================
# Common Naming and Tags Module
# ============================================================================
module "common" {
  source = "../../../modules/common"

  environment  = var.environment
  project_name = var.project_name
  service_name = "k8s"
}

# ============================================================================
# Local Values
# ============================================================================
locals {
  common_tags = merge(
    module.common.common_tags,
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
}
