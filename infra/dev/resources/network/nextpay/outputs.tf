output "vpc_id" {
  description = "VPC ID"
  value       = data.aws_vpc.main.id
}

output "vpc_name" {
  description = "VPC Name"
  value       = var.vpc_name
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = data.aws_vpc.main.cidr_block
}

output "all_subnet_ids" {
  description = "List of all subnet IDs in the VPC"
  value       = data.aws_subnets.all.ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for id, subnet in local.private_subnets : subnet.id]
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for id, subnet in local.public_subnets : subnet.id]
}

output "private_subnet_details" {
  description = "Detailed information about private subnets"
  value = {
    for id, subnet in local.private_subnets : subnet.id => {
      name              = lookup(subnet.tags, "Name", "")
      availability_zone = subnet.availability_zone
      cidr_block        = subnet.cidr_block
    }
  }
}

output "public_subnet_details" {
  description = "Detailed information about public subnets"
  value = {
    for id, subnet in local.public_subnets : subnet.id => {
      name              = lookup(subnet.tags, "Name", "")
      availability_zone = subnet.availability_zone
      cidr_block        = subnet.cidr_block
    }
  }
}
