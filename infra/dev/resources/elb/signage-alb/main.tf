

locals {
  environment     = "dev"
  project_name    = "signage"

  security_group_ids = ["sg-0d8******acc59c5"]
  certificate_arn = "arn:aws:acm:ap-northeast-2:365********91:certificate/e8****f-8d****3f0-99****38fc****8"
}

data "terraform_remote_state" "nextpay-secondary" {
  backend = "s3"
  config = {
    bucket = "nextpay-terraform-state"
    key    = "dev/resources/network/nextpay-secondary-cidr/terraform.tfstate"
    region = var.aws_region
  }
}


module "common" {
  source = "../../../../modules/common"

  environment  = local.environment
  project_name = local.project_name
}


module "singnage-alb" {
  source = "../../../../modules/alb"
  name   = module.common.common_name

  subnet_ids      = data.terraform_remote_state.nextpay-secondary.outputs.public_subnet_ids
  security_groups = local.security_group_ids
  certificate_arn = local.certificate_arn

  tags = module.common.common_tags
}
