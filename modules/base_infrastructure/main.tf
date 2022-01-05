module "aws_provider" {
    source = "../provider"
    region = var.region
}

resource "aws_key_pair" "main" {
  key_name   = var.ssh_pub_key_file_name
  public_key = file("${var.ssh_pub_key_file_path}")
}

resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = var.vpc_name
  }
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "route_to_igw" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "route-to-internet-gateway"
  }
}

resource "aws_subnet" "back_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.11.0/24"
  availability_zone = var.availability_zone_1

  tags = {
    Name = "soar_back_subnet"
  }
}

resource "aws_subnet" "database" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.20.0/24"
  availability_zone = "eu-west-3c"

  tags = {
    Name = "soar_database_subnet"
  }
}
resource "aws_subnet" "front_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.0.0/24"
  availability_zone = "eu-west-3c"

  tags = {
    Name = "soar_front_subnet"
  }
}

resource "aws_route_table_association" "igw-route-to-front" {
  subnet_id      = aws_subnet.front_subnet.id
  route_table_id = aws_route_table.route_to_igw.id
}

resource "aws_route_table_association" "route_subnet_back_to_igw" {
  subnet_id      = aws_subnet.back_subnet.id
  route_table_id = aws_route_table.route_to_igw.id
}

resource "aws_route_table_association" "igw-route-to-database" {
  subnet_id      = aws_subnet.database.id
  route_table_id = aws_route_table.route_to_igw.id
}

module "security_groups" {
    source = "../security_groups"
    vpc_id = aws_vpc.main.id
    vpc_cidr_block = aws_vpc.main.cidr_block
}

resource "aws_eip" "database_eip" {
    vpc = true
}

# Load Balancer operating at OSI 4th layer
resource "aws_elb" "back_load_balancer" {
  name = "back-load-balancer"

  security_groups = [
    module.security_groups.allow_http_sec_group_id,
    module.security_groups.allow_outbound_sec_group_id,
  ]

  subnets = [
    aws_subnet.back_subnet.id,
  ]

  cross_zone_load_balancing   = true

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 29
    interval = 30
    target = "HTTP:80/"
  }

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }
}


# Load Balancer operating at OSI 4th layer
resource "aws_elb" "front_load_balancer" {
  name = "front-load-balancer"

  security_groups = [
    module.security_groups.allow_http_sec_group_id,
    module.security_groups.allow_outbound_sec_group_id,
  ]

  subnets = [
    aws_subnet.front_subnet.id,
  ]

  cross_zone_load_balancing   = true

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 29
    interval = 30
    target = "HTTP:80/"
  }

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }
}

resource "aws_subnet" "subnet_for_image_build" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.subnet_for_image_build_cidr_block
}

resource "aws_route_table_association" "route_subnet_for_image_build_to_igw" {
  subnet_id      = aws_subnet.subnet_for_image_build.id
  route_table_id = aws_route_table.route_to_igw.id
}

# module "build_frontend_ami" {
#     source = "../simple_host"

#     subnet_id = aws_subnet.subnet_for_image_build.id
#     key_name = aws_key_pair.main.key_name
#     vpc_security_group_ids = [
#         module.security_groups.allow_ssh_sec_group_id,
#         module.security_groups.allow_outbound_sec_group_id,
#     ]
#     instance_name = "build_frontend_ami"
# }

# output "build_frontend_ami_instance_ip" {
#     value = "ssh -i soar-key ec2-user@${module.build_frontend_ami.instance_ip}"
# }

# module "build_backend_ami" {
#     source = "../simple_host"

#     subnet_id = aws_subnet.subnet_for_image_build.id
#     key_name = aws_key_pair.main.key_name
#     vpc_security_group_ids = [
#         module.security_groups.allow_ssh_sec_group_id,
#         module.security_groups.allow_outbound_sec_group_id,
#     ]
#     instance_name = "build_backend_ami"
# }

# output "build_backend_ami_instance_ip" {
#     value = "ssh -i soar-key ec2-user@${module.build_backend_ami.instance_ip}"
# }