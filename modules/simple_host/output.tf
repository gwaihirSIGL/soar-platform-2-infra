output "instance_ip" {
  value = aws_eip.instance_elastic_ip.public_ip
}
