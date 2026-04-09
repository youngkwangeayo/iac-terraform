# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = data.aws_vpc.primary_main.id
}

output "vpc_arn" {
  description = "VPC ARN"
  value       = data.aws_vpc.primary_main.arn
}

output "primary_cidr" {
  description = "Primary CIDR block (기존)"
  value       = data.aws_vpc.primary_main.cidr_block
}

output "secondary_cidr" {
  description = "Secondary CIDR block (새로 추가)"
  value       = aws_vpc_ipv4_cidr_block_association.secondary.cidr_block
}

output "secondary_cidr_association_id" {
  description = "Secondary CIDR association ID"
  value       = aws_vpc_ipv4_cidr_block_association.secondary.id
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.pub_subent[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.priv_subnet[*].id
}

output "private_k8s_subnet_ids" {
  description = "List of private K8s subnet IDs"
  value       = var.use_k8s ? aws_subnet.priv_subnet_k8s[*].id : []
}

# Gateway Outputs
output "primary_internet_gateway_id" {
  description = "Primary Internet Gateway ID (기존 재사용)"
  value       = data.aws_internet_gateway.primary_igw.id
}

output "primary_nat_gateway_id" {
  description = "Primary NAT Gateway ID (기존 재사용)"
  value       = data.aws_nat_gateway.primary_nat_gw.id
}

# Route Table Outputs
output "primary_public_route_table_id" {
  description = "Primary public route table ID (기존 재사용)"
  value       = data.aws_route_table.primary_public.id
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = aws_route_table.rtb_private[*].id
}

# Availability Zones
output "availability_zones" {
  description = "List of availability zones used"
  value       = local.az_zone
}
