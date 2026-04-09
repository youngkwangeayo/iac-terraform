variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "alb_name" {
  description = "Name of the existing Application Load Balancer"
  type        = string
}

