output "nat_gateway_subnet_id" {
    value = aws_subnet.ngw_subnet.id
}

output "nat_gateway_id" {
    value = aws_nat_gateway.ngw.id
}
