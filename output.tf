# output "front_dns_address" {
#     value = aws_eip.front_lb.public_dns
# }

output "back_lb_dns_address" {
  value = aws_elb.back_load_balancer.dns_name
}

output "database_dns_address" {
    value = aws_eip.database_lb.public_dns
}
