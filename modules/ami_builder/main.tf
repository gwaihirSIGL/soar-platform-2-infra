resource "aws_subnet" "ami_builder_subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr_block
  availability_zone = "eu-west-3c"

  tags = {
    Name = "ami-builder-subnet"
  }
}

resource "aws_route_table" "route_to_nat_gateway" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_id
  }
  tags = {
    Name = "route-to-nat-gateway"
  }
}

resource "aws_route_table_association" "route_subnet_to_ngw" {
  subnet_id = aws_subnet.ami_builder_subnet.id
  route_table_id = aws_route_table.route_to_nat_gateway.id
}

data "template_file" "bootstrap_script" {
  template = "${file(var.script_file)}"
  vars = var.script_variables
}

resource "aws_instance" "instance" {
  instance_type = var.instance_type
  ami           = var.base_ami
  subnet_id = aws_subnet.ami_builder_subnet.id
  vpc_security_group_ids = var.instance_vpc_security_group_ids
  key_name = var.key_name

  user_data = data.template_file.bootstrap_script.rendered

  tags = {
    "Name" = "ami_builder"
  }
}

resource "aws_eip" "instance_elastic_ip" {
  instance = aws_instance.instance.id
  vpc = true
}

resource "aws_ami_from_instance" "built_ami" {
  name               = "built-ami"
  source_instance_id = aws_instance.instance.id
}
