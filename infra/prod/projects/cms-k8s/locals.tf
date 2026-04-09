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
  # Resource names
  cluster_name   = "eks-${module.common.common_name}"
  nodegroup_name = "nodegroup-${module.common.common_name}"

  # IAM role names
  cluster_role_name            = "eks-cluster-role-${module.common.common_name}"
  node_role_name               = "eks-node-role-${module.common.common_name}"
  alb_controller_role_name     = "alb-controller-role-${module.common.common_name}"
  ebs_csi_driver_role_name     = "ebs-csi-driver-role-${module.common.common_name}"
  cluster_autoscaler_role_name = "cluster-autoscaler-role-${module.common.common_name}"

  # IAM policy names
  alb_controller_policy_name     = "alb-controller-policy-${module.common.common_name}"
  cluster_autoscaler_policy_name = "cluster-autoscaler-policy-${module.common.common_name}"

  # Common tags
  common_tags = merge(
    module.common.common_tags,
    {
      "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    }
  )
}
