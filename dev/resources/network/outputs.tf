output "vpc_id" {
  description = "VPC ID"
  value       = data.aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = data.aws_vpc.selected.cidr_block
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = var.subnet_ids
}

output "subnet_details" {
  description = "Detailed information about subnets"
  value = {
    for idx, subnet in data.aws_subnet.subnets : subnet.id => {
      availability_zone = subnet.availability_zone
      cidr_block        = subnet.cidr_block
    }
  }
}
