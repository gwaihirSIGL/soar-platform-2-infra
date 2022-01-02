resource "aws_subnet" "front" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.0.0/24"
  availability_zone = "eu-west-3c"

  tags = {
    Name = "soar_front_subnet"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table_association" "igw-route-to-front" {
  subnet_id      = aws_subnet.front.id
  route_table_id = aws_route_table.main.id
}

resource "aws_instance" "front_instance" {
  ami           = "ami-0d3c032f5934e1b41"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.front.id
  private_ip    = "192.168.0.50"

  security_groups = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_every_outbound_traffic.id,
    aws_security_group.allow_http.id,
  ]

  key_name = aws_key_pair.main.key_name

  tags = {
    Name = "soar_front_instance"
  }

  user_data = <<EOF
#!/bin/bash
sudo yum update -y
sudo yum install -y git
curl --silent --location https://rpm.nodesource.com/setup_12.x | sudo bash - && sudo yum -y install nodejs
mkdir /app
cd /app
git clone https://${var.gittoken}@github.com/gwaihirSIGL/soar-platform-2-front.git
cd soar-platform-2-front/
echo "REACT_APP_BASE_URL='${aws_eip.back_lb.public_dns}'" > .env
sudo npm i
sudo npm start 1>server_logs.txt 2>&1 &
EOF
}

resource "aws_eip" "front_lb" {
  instance   = aws_instance.front_instance.id
  vpc        = true
}
