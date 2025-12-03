
# ============================================================================
# 타겟유형
# ============================================================================

variable "target_group_arn" {
  description = "The ARN of the target group to attach targets to."
  type        = string
}

variable "target" {
  description = "타겟그룹에 등록할 대상. 추후 생성가능."
  type = list(object({
    target_id = string
    port      = number
  }))
  default = []
}