# Build an instance, and associate it an ip

resource "aws_instance" "instance" {
  instance_type = var.instance_type
  ami           = var.ami
  subnet_id = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  key_name = var.key_name
  disable_api_termination = false
  ebs_optimized = false
  root_block_device {
    volume_size = "10"
  }
  tags = {
    "Name" = var.instance_name
  }
}

resource "aws_eip" "instance_elastic_ip" {
  instance = aws_instance.instance.id
  vpc = true
}
