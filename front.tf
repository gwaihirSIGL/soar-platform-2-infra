
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

resource "aws_key_pair" "main" {
  key_name = "soar_ssh_key"
  public_key = file("./soar-key.pub")
}

resource "aws_instance" "front_instance" {
  ami           = "ami-0d3c032f5934e1b41"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.front.id
  private_ip = "192.168.0.50"

  security_groups = [
      aws_security_group.allow_ssh.id,
      aws_security_group.allow_every_outbound_traffic.id,
  ]

  key_name = aws_key_pair.main.key_name

  tags = {
    Name = "soar_front_instance"
  }


  user_data = <<EOF
#!/bin/bash
touch hello_world
EOF
}

resource "aws_eip" "lb" {
  instance   = aws_instance.front_instance.id
  vpc        = true
  depends_on = [aws_internet_gateway.front_gw]
}