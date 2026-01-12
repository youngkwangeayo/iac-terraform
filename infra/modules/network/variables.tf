# ============================================================================
# 프로젝트 정보
# ============================================================================

variable "name" {
  description = "loadbalancer name"
  type        = string
}


variable "tags" {
  description = "A map of tags to add to the security group"
  type        = map(string)
  default     = {}
}


variable "use_k8s" {
  description = "k8s용 서브넷 사용여부"
  type = bool
  default = false
}