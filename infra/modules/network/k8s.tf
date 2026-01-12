


# 10.0.32.0/20, 10.0.48.0/20, 10.0.64.0/20 
# 10.0.32.0 
#   ~
# 10.0.80.0
resource "aws_subnet" "priv_subnet_k8s" {
  count             = var.use_k8s ? 3 : 0

  vpc_id            = aws_vpc.this.id
  availability_zone = local.az_zone[count.index]
  cidr_block        = "10.0.${32 + (count.index * 16)}.0/20" //4,096

  enable_lni_at_device_index          = 0
  private_dns_hostname_type_on_launch = "ip-name"

  tags = merge(
    var.tags,
    { Name : "priv-subnet-k8s${count.index}-${local.az_zone[count.index]}-${var.name}" }
  )
}


# K8s 서브넷들도 각각의 AZ에 맞는 프라이빗 라우팅 테이블에 연결
resource "aws_route_table_association" "k8s_assoc" {
  count          = var.use_k8s ? 3 : 0
  subnet_id      = aws_subnet.priv_subnet_k8s[count.index].id
  route_table_id = aws_route_table.rtb_private[count.index].id
}