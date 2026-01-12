# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "VPC ARN"
  value       = aws_vpc.this.arn
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.this.cidr_block
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.pub_subent[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.priv_subent[*].id
}

output "private_k8s_subnet_ids" {
  description = "List of private K8s subnet IDs"
  value       = var.use_k8s ? aws_subnet.priv_subnet_k8s[*].id : []
}

# Gateway Outputs
output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.nat-gw.id
}

output "nat_eip" {
  description = "NAT Gateway Elastic IP"
  value       = aws_eip.nat.public_ip
}

# Route Table Outputs
output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.rtb-public.id
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = aws_route_table.rtb-private[*].id
}

# Availability Zones
output "availability_zones" {
  description = "List of availability zones used"
  value       = local.az_zone
}