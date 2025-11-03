# modules/ec2/outputs.tf

output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = aws_instance.this.public_ip
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

output "ami_id" {
  value = data.aws_ami.selected.id
}
