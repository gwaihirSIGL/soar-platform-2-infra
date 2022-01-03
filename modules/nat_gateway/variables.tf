variable "nat_gateway_az" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "internet_gateway_id" {
  type = string
}

variable "nat_gateway_subnet_cidr" {
  type = string
}

variable "instances_to_root_subnet_id" {
    type = string
}
