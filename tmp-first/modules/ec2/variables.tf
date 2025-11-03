#########################################
# EC2 Variables
#########################################


##############
# 프로젝트 환경 #
##############
variable "instance_name" {
  type        = string
  description = "EC2 instance name tag"
}

variable "env" {
  type        = string
  # default     = "dev"
  description = "only ['dev','stg', 'prod']"
  validation {
    condition     = contains(["dev","stg", "prod"], var.env)
    error_message = "only ['dev','stg', 'prod']."
  }
}

variable "project" {
  type = string
  default = ""
  description = "프로젝트네임"
}

variable "extra_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to the instance"
}


############
# 컴퓨팅    #
############

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type"
}

variable "ami_type" {
  type        = string
  default     = "amazon-linux"
  description = "AMI type: ['amazon-linux','ubuntu', 'deeplearning_ubuntu_cuda']"
  validation {
    condition     = contains(["amazon-linux", "ubuntu"], var.ami_type)
    error_message = "ami_type must be either ['amazon-linux','ubuntu', 'deeplearning_ubuntu_cuda']."
  }
}

variable "architecture" {
  type        = string
  default     = "x86_64"
  description = "AMI architecture (x86_64 or arm64)"
}


variable "key_name" {
  type        = string
  default     = null
  description = "Existing key pair name (or create separately)"
}


variable "volume_size" {
  type        = number
  default     = 20
  description = "Root EBS volume size (GB)"
}

variable "volume_type" {
  type        = string
  default     = "gp3"
  description = "EBS volume type (gp3, gp2, io1, etc)"
}

############
# 네트워크    #
############

variable "subnet_id" {
  type        = string
  description = "Subnet ID to launch the instance in"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs"
}

variable "associate_public_ip" {
  type        = bool
  default     = true
  description = "Whether to assign a public IP"
}

