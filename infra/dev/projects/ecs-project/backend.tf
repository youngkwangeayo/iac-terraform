terraform {
  backend "s3" {
    bucket         = "nextpay-terraform-state"
    key            = "dev/projects/tmp-app/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "nextpay-terraform-locks"
    encrypt        = true
  }
}
