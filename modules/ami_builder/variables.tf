variable "vpc_id" {
  type = string
}

variable "subnet_cidr_block" {
  type = string
}

variable "nat_gateway_id" {
  type = string
}

variable "key_name" {
  type = string
}
variable "instance_vpc_security_group_ids" {
  type = list(string)
  default = []
}

variable "script_file" {
  type = string
}

variable "script_variables" {
  type = map(string)
  default = {}
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "base_ami" {
  type = string
  default = "ami-0d3c032f5934e1b41"
}