# ============================================================================
# EKS Node Groups (서비스별 독립 노드그룹)
# ============================================================================
# 각 노드그룹은 service taint로 격리됨
# 서비스 Deployment에 toleration + nodeSelector 필요:
#   tolerations:
#   - key: "service"
#     value: "<service>"   # signage | cms | aiagent
#     effect: "NoSchedule"
#   nodeSelector:
#     Service: <service>
# ============================================================================
resource "aws_eks_node_group" "services" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "nodegroup-${module.common.common_name}-${each.key}"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  update_config {
    max_unavailable = 1
  }

  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = "ON_DEMAND"
  disk_size      = each.value.disk_size
  instance_types = each.value.instance_types

  labels = {
    Environment = var.environment
    Project     = var.project_name
    node-role   = each.key
  }

  taint {
    key    = "node-role"
    value  = each.key
    effect = "NO_SCHEDULE"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = merge(local.common_tags, { Service = each.key })
}
