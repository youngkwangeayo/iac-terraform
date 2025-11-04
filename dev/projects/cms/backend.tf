terraform {
  backend "s3" {
    bucket         = "terraform-state-dev-cms"
    key            = "dev/projects/cms/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-lock-dev"
    encrypt        = true
  }
}
