variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "vpc_name" {
  description = "Name tag of the existing VPC to reference"
  type        = string
  default     = "default"
}

variable "subnet_ids" {
  description = "List of subnet IDs to reference (from aws-def/service-dev.json)"
  type        = list(string)
  default = [
    "subnet-08be2b5dba489c093",
    "subnet-0aa888b710602c0be",
    "subnet-0efb01644999a3129"
  ]
}
