
# 172.16.32.0/20, 172.16.48.0/20, 172.16.64.0/20 
# 172.16.32.0 
#   ~
# 172.16.80.0
resource "aws_subnet" "priv_subnet_k8s" {
  count             = var.use_k8s ? 3 : 0

  vpc_id            = data.aws_vpc.primary_main.id
  availability_zone = local.az_zone[count.index]
  cidr_block        = "172.16.${32 + (count.index * 16)}.0/20" //4,096

  private_dns_hostname_type_on_launch = "ip-name"

  tags = merge(
    module.common.common_tags,
    { Name : "priv-subnet-k8s${count.index}-${local.az[count.index]}-${module.common.common_name}" }
  )

  # Secondary CIDR가 VPC에 추가된 후에 서브넷 생성
  depends_on = [aws_vpc_ipv4_cidr_block_association.secondary]
}


# K8s 서브넷들도 각각의 AZ에 맞는 프라이빗 라우팅 테이블에 연결
resource "aws_route_table_association" "k8s_assoc" {
  count          = var.use_k8s ? 3 : 0
  subnet_id      = aws_subnet.priv_subnet_k8s[count.index].id
  route_table_id = aws_route_table.rtb_private[count.index].id
}