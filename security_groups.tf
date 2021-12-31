resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "allow_ingress_mysql" {
  name        = "allow_ingress_mysql_connections_from_back_subnet"
  description = "Allow ingress mysql connections from back subnet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "ingress_mysql_connection"
    from_port   = 5444
    to_port     = 5444
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.back.cidr_block]
  }

  tags = {
    Name = "allow_mysql"
  }
}

resource "aws_security_group" "allow_every_outbound_traffic" {
  name        = "allow_every_outbound_traffic"
  description = "Allow every outbond traffic"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_every_outbound_traffic"
  }
}
