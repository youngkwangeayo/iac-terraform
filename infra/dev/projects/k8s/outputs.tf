# ============================================================================
# Cluster Outputs
# ============================================================================
output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.cms.id
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.cms.name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.cms.endpoint
}

output "cluster_certificate_authority" {
  description = "EKS cluster certificate authority data"
  value       = aws_eks_cluster.cms.certificate_authority[0].data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = aws_eks_cluster.cms.vpc_config[0].cluster_security_group_id
}

output "cluster_oidc_issuer_url" {
  description = "EKS cluster OIDC issuer URL"
  value       = aws_eks_cluster.cms.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN"
  value       = aws_iam_openid_connect_provider.cluster.arn
}

# ============================================================================
# Node Group Outputs
# ============================================================================
output "node_group_id" {
  description = "EKS node group ID"
  value       = aws_eks_node_group.cms.id
}

output "node_group_status" {
  description = "EKS node group status"
  value       = aws_eks_node_group.cms.status
}

# ============================================================================
# IAM Role Outputs
# ============================================================================
output "cluster_role_arn" {
  description = "EKS cluster IAM role ARN"
  value       = aws_iam_role.cluster.arn
}

output "node_role_arn" {
  description = "EKS node group IAM role ARN"
  value       = aws_iam_role.node.arn
}

output "alb_controller_role_arn" {
  description = "ALB Controller IAM role ARN"
  value       = aws_iam_role.alb_controller.arn
}

output "ebs_csi_driver_role_arn" {
  description = "EBS CSI Driver IAM role ARN"
  value       = aws_iam_role.ebs_csi_driver.arn
}

output "cluster_autoscaler_role_arn" {
  description = "Cluster Autoscaler IAM role ARN"
  value       = aws_iam_role.cluster_autoscaler.arn
}

# ============================================================================
# Helm Release Outputs
# ============================================================================
output "metrics_server_status" {
  description = "Metrics Server Helm release status"
  value       = helm_release.metrics_server.status
}

output "alb_controller_status" {
  description = "ALB Controller Helm release status"
  value       = helm_release.alb_controller.status
}

output "cluster_autoscaler_status" {
  description = "Cluster Autoscaler Helm release status"
  value       = helm_release.cluster_autoscaler.status
}

# ============================================================================
# Configuration Commands
# ============================================================================
output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.cms.name}"
}

# ============================================================================
# Additional Info
# ============================================================================

output "acm_certificate_arn" {
  description = "ACM certificate ARN for nextpay.co.kr"
  value       = data.aws_acm_certificate.nextpay.arn
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID"
  value       = data.aws_route53_zone.nextpay.zone_id
}
