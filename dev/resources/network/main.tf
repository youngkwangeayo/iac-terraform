# 기존 VPC 참조
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# 기존 Subnet 참조
data "aws_subnet" "subnets" {
  count = length(var.subnet_ids)
  id    = var.subnet_ids[count.index]
}

# VPC CIDR 블록 정보
data "aws_vpc" "selected" {
  id = data.aws_vpc.main.id
}
