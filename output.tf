output "dns" {
    value = aws_instance.front_instance.public_ip
}
