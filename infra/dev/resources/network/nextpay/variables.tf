variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "vpc_name" {
  description = "Name tag of the existing VPC to reference"
  type        = string
  default     = "dev-vpc"
}
