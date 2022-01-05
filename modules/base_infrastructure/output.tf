output "vpc_name" {
    value = var.vpc_name
}

# output "subnet_id_for_image_build" {
#     value = aws_subnet.subnet_for_image_build.id
# }

output "vpc_id" {
    value = aws_vpc.main.id
}

output "allow_ssh_sec_group_id" {
    value = module.security_groups.allow_ssh_sec_group_id
}

output "allow_http_sec_group_id" {
    value = module.security_groups.allow_http_sec_group_id
}

output "allow_outbound_sec_group_id" {
    value = module.security_groups.allow_outbound_sec_group_id
}

output "allow_ingress_mysql_from_vpc_id" {
    value = module.security_groups.allow_ingress_mysql_from_vpc_id
}

output "back_lb_id" {
    value = aws_elb.back_load_balancer.id
}

output "back_lb_dns_name" {
    value = aws_elb.back_load_balancer.dns_name
}

output "front_lb_id" {
    value = aws_elb.front_load_balancer.id
}

output "front_lb_dns_name" {
    value = aws_elb.front_load_balancer.dns_name
}

output "database_eip" {
    value = aws_eip.database_eip.public_ip
}

output "database_allocation_ip_id" {
    value = aws_eip.database_eip.id
}

output "database_subnet_id" {
    value = aws_subnet.database.id
}

output "front_subnet_id" {
    value = aws_subnet.front_subnet.id
}

output "ssh_pub_key_file_name" {
    value = var.ssh_pub_key_file_name
}

output "back_subnet_id" {
    value = aws_subnet.back_subnet.id
}

output "internet_gateway_id" {
    value = aws_internet_gateway.igw.id
}