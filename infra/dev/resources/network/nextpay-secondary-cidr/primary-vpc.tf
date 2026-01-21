
# ---------------------------------------------------------
# 기존 VPC 참조
# ---------------------------------------------------------
data "aws_vpc" "primary_main" {
  filter {
    name   = "tag:Name"
    values = [var.primary_vpc_name]
  }
}


# ---------------------------------------------------------
# 기존 NAT Gateway 참조 (재사용)
# ---------------------------------------------------------
data "aws_nat_gateways" "primary_nat_gateways" {
  vpc_id = data.aws_vpc.primary_main.id
}

data "aws_nat_gateway" "primary_nat_gw" {
  id = tolist(data.aws_nat_gateways.primary_nat_gateways.ids)[0]
}


# ---------------------------------------------------------
# 기존 Internet Gateway 참조 (재사용)
# ---------------------------------------------------------
data "aws_internet_gateway" "primary_igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.primary_main.id]
  }
}


# ---------------------------------------------------------
# 기존 Public 라우팅 테이블 참조 (재사용)
# ---------------------------------------------------------
data "aws_route_table" "primary_public" {
  route_table_id = var.primary_rtb_pub_id
}
