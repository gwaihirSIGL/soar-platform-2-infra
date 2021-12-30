output "front_dns_address" {
    value = aws_eip.front_lb.public_dns
}

output "back_dns_address" {
    value = aws_eip.back_lb.public_dns
}

output "database_dns_address" {
    value = aws_eip.database_lb.public_dns
}
