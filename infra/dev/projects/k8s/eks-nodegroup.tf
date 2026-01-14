# ============================================================================
# Launch Template for Node Group
# ============================================================================
# NOTE: Commented out for initial testing. VPC ID is explicitly set in ALB Controller.
# Uncomment if IMDS access is still needed after testing.
#
# resource "aws_launch_template" "node_group" {
#   name = "launch-template-${local.nodegroup_name}"
#
#   metadata_options {
#     http_endpoint               = "enabled"
#     http_tokens                 = "required"  # IMDSv2
#     http_put_response_hop_limit = 2           # Allow Pod access to IMDS
#     instance_metadata_tags      = "disabled"
#   }
#
#   tag_specifications {
#     resource_type = "instance"
#     tags          = local.common_tags
#   }
# }

# ============================================================================
# EKS Node Group
# ============================================================================
resource "aws_eks_node_group" "cms" {
  cluster_name    = aws_eks_cluster.cms.name
  node_group_name = local.nodegroup_name
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  update_config {
    max_unavailable = 1
  }

  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = "ON_DEMAND"
  disk_size      = var.node_disk_size
  instance_types = var.node_instance_types

  labels = {
    Environment = var.environment
    Project     = var.project_name
  }

  # Enable IMDSv2 for Pod access to instance metadata
  # NOTE: Commented out for initial testing with explicit VPC ID in ALB Controller
  # launch_template {
  #   name    = aws_launch_template.node_group.name
  #   version = "$Latest"
  # }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = local.common_tags
}
