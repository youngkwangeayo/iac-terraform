
variable "v1" {
  description = "value"
  default     = null
}

resource "local_file" "first" {
  filename = "${path.module}/../../tmp-garbage/second.txt"
}

# resource "local_file" "second" {
#   content = "두번째! + 내용을 변경"
#   file_permission = "0400"
#   filename = "${path.module}/../../tmp-garbage/second.txt"
# }

# resource "local_file" "third" {
#   content = "세번째 + 내용추가"
#   filename = "${path.module}/../../tmp-garbage/third.txt"
# }

# moved {
#   from = local_file.first1
#   to = local_file.first
# }

# output "local_file_output" {
#   value = local_file.first.directory_permission
# }
