


# 가용영역 리스트 정의
locals {
  az_zone = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
  az      = ["2a", "2b", "2c"]
}



resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16" //65,536개 IP

  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    var.tags,
    { Name : "vpc-${var.name}" }
  )
}



# 10.0.0.0/24 ~ 10.0.2.0/24
resource "aws_subnet" "pub_subent" {
  count = 3

  vpc_id            = aws_vpc.this.id
  availability_zone = local.az_zone[count.index]
  cidr_block        = "10.0.${count.index}.0/24"

  enable_lni_at_device_index          = 0
  private_dns_hostname_type_on_launch = "ip-name"

  tags = merge(
    var.tags,
    { Name : "pub-subnet${count.index}-${local.az_zone[count.index]}-${var.name}" }
  )
}


# 10.0.10.0/24 ~ 10.0.19.0/24
resource "aws_subnet" "priv_subent" {
  count = 3

  vpc_id            = aws_vpc.this.id
  availability_zone = local.az_zone[count.index]
  cidr_block        = "10.0.${10 + count.index}.0/24"

  enable_lni_at_device_index          = 0
  private_dns_hostname_type_on_launch = "ip-name"

  tags = merge(
    var.tags,
    { Name : "priv-subnet${count.index}-${local.az_zone[count.index]}-${var.name}" }
  )
}



# ---------------------------------------------------------
# 네트워크
# ---------------------------------------------------------

# 인터넷 게이트웨이
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    var.tags,
    { Name : "igw-${var.name}" }
  )
}


# NAT 게이트웨이가 사용할 고정 IP(EIP) 할당
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = merge(
    var.tags,
    { Name : "nat-eip-${var.name}" }
  )
}

# 2. NAT 게이트웨이 생성 (첫 번째 퍼블릭 서브넷에 배치)
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.pub_subent[0].id

  tags = merge(
    var.tags,
    { Name : "nat-gw-${local.az[0]}-${var.name}" }
  )

  depends_on = [aws_internet_gateway.igw]
}



# ---------------------------------------------------------
# 퍼블릿 라우팅
# ---------------------------------------------------------
# Public용 공용 라우팅 테이블
resource "aws_route_table" "rtb-public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(
    var.tags,
    { Name : "rtb-public-${var.name}" }
  )
}
# 퍼브릿 연결
resource "aws_route_table_association" "public_assoc" {
  count          = 3
  subnet_id      = aws_subnet.pub_subent[count.index].id
  route_table_id = aws_route_table.rtb-public.id
}



# ---------------------------------------------------------
# 프라이빗 라우팅
# ---------------------------------------------------------
# Private용 AZ별 독립 라우팅 테이블
resource "aws_route_table" "rtb-private" {
  count  = 3
  vpc_id = aws_vpc.this.id
  tags = merge(
    var.tags,
    { Name : "rtb-private-${local.az_zone[count.index]}-${var.name}" }
  )
}
# 프라이빗 연결
resource "aws_route_table_association" "private_assoc" {
  count          = 3
  subnet_id      = aws_subnet.priv_subent[count.index].id
  route_table_id = aws_route_table.rtb-private[count.index].id
}


# 기존 Private 라우팅 테이블(3개)에 NAT 게이트웨이 경로 추가
resource "aws_route" "private_nat_route" {
  count                  = 3
  route_table_id         = aws_route_table.rtb-private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gw.id
}
