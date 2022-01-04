resource "aws_subnet" "ngw_subnet" {
  availability_zone = var.nat_gateway_az
  cidr_block = var.nat_gateway_subnet_cidr
  vpc_id = var.vpc_id
  tags = {
    "Name" = "SubnetNAT"
  }
}

resource "aws_route_table" "route_to_igw" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }
  tags = {
    Name = "route-to-internet-gateway-ami-builder"
  }
}

resource "aws_route_table_association" "route_ngw_subnet_to_igw" {
  subnet_id = aws_subnet.ngw_subnet.id
  route_table_id = aws_route_table.route_to_igw.id
}

resource "aws_eip" "ngw_ip" {
  vpc = true
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw_ip.id
  subnet_id = aws_subnet.ngw_subnet.id
  tags = {
    "Name" = "NatGateway"
  }
}

output "nat_gateway_ip" {
  value = aws_eip.ngw_ip.public_ip
}

# resource "aws_route_table" "route_to_ngw" {
#   vpc_id = var.vpc_id
#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.ngw.id
#   }
#   tags = {
#     Name = "route-to-nat-gateway-ami-builder"
#   }
# }

# resource "aws_route_table_association" "route_subnet_to_ngw" {
#   subnet_id = var.instances_to_root_subnet_id
#   route_table_id = aws_route_table.route_to_ngw.id
# }
