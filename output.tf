output "instance_ip" {
  value = aws_instance.leafny_web.public_ip
}

output "eip" {
  value = aws_eip.leafny_eip.public_ip
}

output "ami_id" {
  value = aws_ami_from_instance.leafny_ami.id
}