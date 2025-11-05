# 기존 VPC 참조
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# VPC의 모든 Subnet 자동 참조
data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

# 각 Subnet의 상세 정보 참조
data "aws_subnet" "details" {
  for_each = toset(data.aws_subnets.all.ids)
  id       = each.value
}

# Private/Public Subnet 필터링 (소문자 private/public 기준)
locals {
  private_subnets = {
    for id, subnet in data.aws_subnet.details :
    id => subnet
    if can(regex(".*private.*|.*pvt.*", lower(lookup(subnet.tags, "Name", ""))))
  }

  public_subnets = {
    for id, subnet in data.aws_subnet.details :
    id => subnet
    if can(regex(".*public.*", lower(lookup(subnet.tags, "Name", ""))))
  }
}
