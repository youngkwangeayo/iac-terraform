# ============================================================================
# EKS Cluster
# ============================================================================
resource "aws_eks_cluster" "cms" {
  name     = local.cluster_name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"] # TODO: Restrict in production
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.service_ipv4_cidr # 10.200.0.0/16
    ip_family         = "ipv4"
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController,
  ]

  tags = local.common_tags
}
