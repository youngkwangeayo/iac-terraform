# ============================================================================
# Network Data Sources
# ============================================================================
data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnets" "k8s" {
  filter {
    name   = "subnet-id"
    values = var.subnet_ids
  }
}

data "aws_subnet" "k8s" {
  for_each = toset(var.subnet_ids)
  id       = each.value
}

# ============================================================================
# OIDC Provider Data (for IRSA)
# ============================================================================
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.cms.identity[0].oidc[0].issuer
}

# ============================================================================
# Current AWS Account
# ============================================================================
data "aws_caller_identity" "current" {}

# ============================================================================
# EKS Add-on Versions
# ============================================================================
data "aws_eks_addon_version" "vpc_cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

data "aws_eks_addon_version" "coredns" {
  addon_name         = "coredns"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

data "aws_eks_addon_version" "kube_proxy" {
  addon_name         = "kube-proxy"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

data "aws_eks_addon_version" "ebs_csi_driver" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

# ============================================================================
# ECR Repository (for reference)
# ============================================================================
data "aws_ecr_repository" "cms" {
  name = "dev-cms"
}

# ============================================================================
# ACM Certificate
# ============================================================================
data "aws_acm_certificate" "nextpay" {
  domain   = "*.nextpay.co.kr"
  statuses = ["ISSUED"]
}

# ============================================================================
# Route53 Zone
# ============================================================================
data "aws_route53_zone" "nextpay" {
  zone_id = "Z075035514XCM0YECN764"
}
