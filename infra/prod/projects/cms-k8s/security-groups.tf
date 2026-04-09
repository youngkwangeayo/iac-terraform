# ============================================================================
# EKS Cluster Security Group Additional Rules
# ============================================================================
# Note: EKS automatically creates a cluster security group.
# This rule allows workstation access to the API server.

resource "aws_security_group_rule" "cluster_ingress_workstation_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # TODO: Restrict in production
  security_group_id = aws_eks_cluster.cms.vpc_config[0].cluster_security_group_id
  description       = "Allow workstation to communicate with the cluster API Server"
}

# ============================================================================
# Node Security Group
# ============================================================================
# Note: EKS automatically creates and manages the node security group.
# No additional configuration required.
