
//==========ELB===================

variable "internal" {

}
variable "load_balancer_type" {

}
variable "subnet_ids" {

}
variable "security_groups" {

}

//=============================
//=======LIstener=================
variable "certificate_arn" {

}


variable "additional_certificate_arn" {
  description = "추가 CA 인증"
  type = list(string)
}
//=============================
