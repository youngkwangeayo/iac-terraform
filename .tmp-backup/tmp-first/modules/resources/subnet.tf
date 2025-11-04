####################################
# 🔹 입력 변수
####################################
variable "az" {
  description = "조회할 가용 영역 (예: ap-northeast-2a). 비워두면 전체 조회"
  type        = string
  default     = null
}

variable "subnet_name" {
  description = "특정 서브넷 이름(tag:Name). 비워두면 전체 조회"
  type        = string
  default     = null
}



# 첫 번째 서브넷 정보 가져오기 (참조용)
data "aws_subnet" "first" {
  id = try(data.aws_subnets.filtered.ids[0], null)
}

####################################
# 🔹 Outputs
####################################
output "subnet_ids" {
  description = "조회된 모든 서브넷 ID"
  value       = data.aws_subnets.filtered.ids
}

output "first_subnet_id" {
  description = "첫 번째 서브넷 ID"
  value       = try(data.aws_subnet.first.id, null)
}

output "first_subnet_name" {
  description = "첫 번째 서브넷의 Name 태그"
  value       = try(data.aws_subnet.first.tags["Name"], null)
}

output "first_subnet_az" {
  description = "첫 번째 서브넷의 가용 영역"
  value       = try(data.aws_subnet.first.availability_zone, null)
}

# 이름 기반 public/private 분류 (optional)
output "public_subnet_ids" {
  description = "이름에 'public'이 포함된 서브넷 목록"
  value = [
    for id in data.aws_subnets.filtered.ids :
    id if can(regex("(?i)public", try(data.aws_subnet.first.tags["Name"], "")))
  ]
}

output "private_subnet_ids" {
  description = "이름에 'private'이 포함된 서브넷 목록"
  value = [
    for id in data.aws_subnets.filtered.ids :
    id if can(regex("(?i)private", try(data.aws_subnet.first.tags["Name"], "")))
  ]
}
