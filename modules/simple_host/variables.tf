variable "subnet_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
  default = []
}

variable "instance_name" {
  type = string
  default = "simple_host" 
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "ami" {
  type = string
  default = "ami-0d3c032f5934e1b41"
}
