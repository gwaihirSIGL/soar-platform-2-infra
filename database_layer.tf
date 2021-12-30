resource "aws_subnet" "database" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "eu-west-3c"

  tags = {
    Name = "soar_database_subnet"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table_association" "igw-route-to-database" {
  subnet_id      = aws_subnet.database.id
  route_table_id = aws_route_table.main.id
}

resource "aws_instance" "database_instance" {
  ami           = "ami-0d3c032f5934e1b41"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.database.id
  private_ip    = "192.168.1.50"

  security_groups = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_every_outbound_traffic.id,
  ]

  key_name = aws_key_pair.main.key_name

  tags = {
    Name = "soar_database_instance"
  }

  user_data = <<EOF
#!/bin/bash
sudo yum update -y
sudo yum install -y mysql-server
EOF
}

resource "aws_eip" "databse_lb" {
  instance   = aws_instance.back_instance.id
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}
