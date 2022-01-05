output "allow_ssh_sec_group_id" {
    value = aws_security_group.allow_ssh.id
}

output "allow_http_sec_group_id" {
    value = aws_security_group.allow_http.id
}

output "allow_outbound_sec_group_id" {
    value = aws_security_group.allow_every_outbound_traffic.id
}

output "allow_ingress_mysql_from_vpc_id" {
    value = aws_security_group.allow_ingress_mysql_from_vpc.id
}
