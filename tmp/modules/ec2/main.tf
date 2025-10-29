
##############################
# 🔹 SSH Key 자동 생성 (key_name이 null일 때)
##############################
resource "tls_private_key" "generated" {
  count     = var.key_name == null ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated" {
  count      = var.key_name == null ? 1 : 0
  key_name   = var.project != "" ? "${var.project}-${var.env}-key" : "${var.instance_name}-${var.env}-key"
  # key_name   = "${var.project}-${var.env}-key"
  public_key = tls_private_key.generated[0].public_key_openssh
}

resource "local_file" "private_key" {
  count    = var.key_name == null ? 1 : 0
  filename = "${path.module}/${var.project}-${var.env}-generated.pem"
  content  = tls_private_key.generated[0].private_key_pem
  file_permission = "0400"
}

##############################
# 🔹 EC2 Instance
##############################
resource "aws_instance" "this" {
  ami                         = local.ami_type[var.ami_type]
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids

  key_name = var.key_name != null ? var.key_name : aws_key_pair.generated[0].key_name

  associate_public_ip_address = var.associate_public_ip

  # 루트 볼륨 설정
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
    encrypted   = true
  }

  tags = merge(
    {
      Name = "ec2-${var.env}-${var.instance_name}"
      Project = var.project
    },
    var.extra_tags
  )

  lifecycle {
    ignore_changes = [ami]
  }
}

##############################
# 🔹 출력값
##############################
output "instance_id" {
  description = "생성된 EC2 인스턴스 ID"
  value       = aws_instance.this.id
}

output "key_name" {
  description = "사용된 키 이름 (기존 or 신규 생성)"
  value       = var.key_name != null ? var.key_name : aws_key_pair.generated[0].key_name
}

output "private_key_path" {
  description = "신규 키가 생성된 경우 PEM 파일 경로"
  value       = var.key_name == null ? local_file.private_key[0].filename : null
}

output "private_key_pem" {
  description = "신규 키의 개인키 내용 (민감정보)"
  value       = var.key_name == null ? tls_private_key.generated[0].private_key_pem : null
  sensitive   = true
}
