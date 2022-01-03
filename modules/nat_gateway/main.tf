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

resource "aws_route_table" "route_to_ngw" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
}

resource "aws_route_table_association" "route_subnet_to_ngw" {
  subnet_id = var.instances_to_root_subnet_id
  route_table_id = aws_route_table.route_to_ngw.id
}

# resource "aws_subnet" "nat_subnet_eu_west_3c" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "192.168.12.0/24"
#   availability_zone = "eu-west-3c"

#   tags = {
#     Name = "nat_subnet_eu_west_3c"
#   }

#   depends_on = [aws_internet_gateway.igw]
# }

# resource "aws_route_table_association" "igw_route_to_back_eu_west_3c" {
#   subnet_id      = aws_subnet.nat_subnet_eu_west_3c.id
#   route_table_id = aws_route_table.root_to_igw.id
# }

# resource "aws_eip" "nat_gateway_eip_eu_west_3c" {
#   vpc = true
# }
# resource "aws_nat_gateway" "nat_gateway_eu_west_3c" {
#   allocation_id = aws_eip.nat_gateway_eip_eu_west_3c.id
#   subnet_id = aws_subnet.nat_subnet_eu_west_3c.id
#   tags = {
#     "Name" = "NatGateway"
#   }
# }

# resource "aws_route_table" "route_to_nat_eu_west_3c" {
#   vpc_id = aws_vpc.main.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat_gateway_eu_west_3c.id
#   }
# }

# resource "aws_route_table_association" "route_back_to_nat_eu_west_3c" {
#   subnet_id      = aws_subnet.back_subnet_eu_west_3c.id
#   route_table_id = aws_route_table.route_to_nat_eu_west_3c.id
# }
