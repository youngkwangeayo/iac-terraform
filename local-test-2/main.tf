
resource "local_file" "first" {
  content = "첫번째"
  filename = "${path.module}/result/first.txt"
}

resource "local_file" "second" {
  content = "두번째!"
  filename = "${path.module}/result/second.txt"
}

resource "local_file" "third" {
  content = "세번째 + 내용추가"
  filename = "${path.module}/result/third.txt"
}

moved {
  from = local_file.first1
  to = local_file.first
}

output "local_file_output" {
  value = local_file.first.directory_permission
}