# ============================================================================
# VPC CNI (Required)
# ============================================================================
resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.cms.name
  addon_name                  = "vpc-cni"
  addon_version               = data.aws_eks_addon_version.vpc_cni.version
  resolve_conflicts_on_update = "OVERWRITE"

  tags = local.common_tags
}

# ============================================================================
# CoreDNS (Required)
# ============================================================================
resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.cms.name
  addon_name                  = "coredns"
  addon_version               = data.aws_eks_addon_version.coredns.version
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.cms]

  tags = local.common_tags
}

# ============================================================================
# kube-proxy (Required)
# ============================================================================
resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.cms.name
  addon_name                  = "kube-proxy"
  addon_version               = data.aws_eks_addon_version.kube_proxy.version
  resolve_conflicts_on_update = "OVERWRITE"

  tags = local.common_tags
}

# ============================================================================
# EBS CSI Driver
# ============================================================================
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name                = aws_eks_cluster.cms.name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = data.aws_eks_addon_version.ebs_csi_driver.version
  service_account_role_arn    = aws_iam_role.ebs_csi_driver.arn
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.cms]

  tags = local.common_tags
}
