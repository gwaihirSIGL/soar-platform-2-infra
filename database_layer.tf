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
  private_ip    = "192.168.2.50"

  security_groups = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_every_outbound_traffic.id,
    aws_security_group.allow_ingress_mysql.id,
  ]

  key_name = aws_key_pair.main.key_name

  tags = {
    Name = "soar_database_instance"
  }

  user_data = <<EOF
#!/bin/bash
sudo yum update -y
sudo wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm && sudo rpm -Uvh mysql80-community-release-el7-3.noarch.rpm && sudo yum install -y mysql-server
sudo systemctl start mysqld

# Perform mysql_secure_installation cli non interractively
tmp_password=$(sudo grep 'password' /var/log/mysqld.log | cut -b 113-124 -)
myql --user=root -p$tmp_password <<_EOF_
UPDATE mysql.user SET Password=PASSWORD('${var.database_password}') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
_EOF_

# Create DB user
myql --user=root -p${var.database_password} <<_EOF_
CREATE USER '${var.database_user}'@'%' IDENTIFIED BY '${var.database_password}';
GRANT ALL PRIVILEGES ON *.* TO '${var.database_user}'@'%';
FLUSH PRIVILEGES;
_EOF_
EOF
}

resource "aws_eip" "database_lb" {
  instance   = aws_instance.database_instance.id
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}
