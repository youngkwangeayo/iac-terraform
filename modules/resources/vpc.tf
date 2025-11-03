


data "aws_vpc" "selected" {
  filter {
    name = "tag:Name"
    values = [var.vpc_name]
  }
}


output "vpc_id" {
  value = data.aws_vpc.selected.id
}
output "vpc_name" {
  value = data.aws_vpc.selected.tags.Name 
}
# output "vpc_subne" {
#   value = data.aws_vpc.selected.tags.Name // data.aws_ami.selected.id
# }

