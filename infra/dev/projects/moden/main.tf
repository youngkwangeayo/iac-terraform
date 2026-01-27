# ============================================================================
# Remote State 참조 - 공통 인프라 리소스
# ============================================================================

# Network 정보 참조 (dev-vpc)
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "nextpay-terraform-state"
    key    = "dev/resources/network/nextpay/terraform.tfstate"
    region = var.aws_region
  }
}

# ELB 정보 참조 (nextpay ELB)
data "terraform_remote_state" "elb" {
  backend = "s3"
  config = {
    bucket = "nextpay-terraform-state"
    key    = "dev/resources/elb/nextpay/terraform.tfstate"
    region = var.aws_region
  }
}


# ============================================================================
# EC2 인스턴스 참조
# ============================================================================

data "aws_instance" "signage" {
  instance_id = var.ec2_instance_id
}


# ============================================================================
# 공통 네이밍 (프로젝트 레벨)
# ============================================================================

module "common" {
  source = "../../../modules/common"

  environment  = var.environment
  project_name = var.project_name
}


# ============================================================================
# Security Group - 타겟 포트 인바운드 허용
# ============================================================================

locals {
  target_ports = [var.app2_target_port, var.app1_target_port]
}

module "security_group" {
  source = "../../../modules/security-group"

  name        = module.common.common_name
  description = "Security group for Signage EC2 - target port inbound"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = [
    for port in local.target_ports : {
      from_port       = port
      to_port         = port
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
      description     = "Allow inbound TCP ${port}"
    }
  ]

  tags = module.common.common_tags
}

# EC2 인스턴스에 Security Group 연결
resource "aws_network_interface_sg_attachment" "signage" {
  security_group_id    = module.security_group.security_group_id
  network_interface_id = data.aws_instance.signage.network_interface_id
}
