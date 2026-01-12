# ============================================================================
# 공통 네이밍 및 태그 모듈
# ============================================================================

module "common" {
  source = "../../../../modules/common"

  environment   = var.environment
  project_name  = var.project_name
  service_name = var.service_name
}

# 가용영역 리스트 정의
locals {
  az_zone = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
  az      = ["2a", "2b", "2c"]
}


# ---------------------------------------------------------
# Secondary CIDR 추가
# ---------------------------------------------------------
resource "aws_vpc_ipv4_cidr_block_association" "secondary" {
  vpc_id     = data.aws_vpc.primary_main.id
  cidr_block = "172.16.0.0/16" //65,536개 IP
}


# ---------------------------------------------------------
# 퍼블릭 서브넷 생성 (172.16.0.0/24 ~ 172.16.2.0/24)
# ---------------------------------------------------------
resource "aws_subnet" "pub_subent" {
  count = 3

  vpc_id            = data.aws_vpc.primary_main.id
  availability_zone = local.az_zone[count.index]
  cidr_block        = "172.16.${count.index}.0/24"

  enable_lni_at_device_index          = 0
  private_dns_hostname_type_on_launch = "ip-name"

  tags = merge(
    module.common.common_tags,
    { Name : "pub-subnet${count.index}-${local.az_zone[count.index]}-${module.common.common_name}" }
  )

  # Secondary CIDR가 VPC에 추가된 후에 서브넷 생성
  depends_on = [aws_vpc_ipv4_cidr_block_association.secondary]
}

# ---------------------------------------------------------
# 퍼블릭 서브넷과 기존 퍼블릭 라우팅 테이블 연결 (라우팅)
# ---------------------------------------------------------
resource "aws_route_table_association" "public_assoc" {
  count          = 3
  subnet_id      = aws_subnet.pub_subent[count.index].id
  route_table_id = data.aws_route_table.primary_public.id
}


# ---------------------------------------------------------
# 프라이빗 서브넷 생성 (172.16.172.16/24 ~ 172.16.12.0/24)
# ---------------------------------------------------------
resource "aws_subnet" "priv_subnet" {
  count = 3

  vpc_id            = data.aws_vpc.primary_main.id
  availability_zone = local.az_zone[count.index]
  cidr_block        = "172.16.${10 + count.index}.0/24"

  enable_lni_at_device_index          = 0
  private_dns_hostname_type_on_launch = "ip-name"

  tags = merge(
    module.common.common_tags,
    { Name : "priv-subnet${count.index}-${local.az_zone[count.index]}-${module.common.common_name}" }
  )

  # Secondary CIDR가 VPC에 추가된 후에 서브넷 생성
  depends_on = [aws_vpc_ipv4_cidr_block_association.secondary]
}




# ---------------------------------------------------------
# 프라이빗 라우팅
# ---------------------------------------------------------
# Private용 AZ별 독립 라우팅 테이블
resource "aws_route_table" "rtb_private" {
  count  = 3
  vpc_id = data.aws_vpc.primary_main.id

  tags = merge(
    module.common.common_tags,
    { Name : "rtb-private-${local.az_zone[count.index]}-${module.common.common_name}" }
  )
}
# 프라이빗 서브넷과 라우팅 테이블 연결
resource "aws_route_table_association" "private_assoc" {
  count          = 3
  subnet_id      = aws_subnet.priv_subnet[count.index].id
  route_table_id = aws_route_table.rtb_private[count.index].id
}

# Private 라우팅 테이블(3개)에 기존 NAT Gateway 경로 추가
resource "aws_route" "private_nat_route" {
  count                  = 3
  route_table_id         = aws_route_table.rtb_private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = data.aws_nat_gateway.primary_nat_gw.id
}
