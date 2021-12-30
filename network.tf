
resource "aws_internet_gateway" "front_gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "front" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.0.0/24"
  availability_zone = "eu-west-3c"

  tags = {
    Name = "soar_front_subnet"
  }

  depends_on = [aws_internet_gateway.front_gw]
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.front_gw.id
  }
  tags = {
    Name = "main-routing-table"
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.front.id
  route_table_id = aws_route_table.main.id
}
