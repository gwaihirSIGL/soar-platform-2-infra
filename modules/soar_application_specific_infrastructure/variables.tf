variable "region" {
  type = string
  default = "eu-west-3"
}

variable "database_subnet_id" {
  type = string
}

variable "allow_ingress_mysql_from_vpc_id" {
  type = string
}

variable "allow_http_sec_group_id" {
  type = string
}

variable "allow_ssh_sec_group_id" {
  type = string
}

variable "allow_outbound_sec_group_id" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
  default = []
}

variable "database_user" {
  type = string
  default = "admin"
}

variable "database_password" {
  type = string
  default = "admin"
}

variable "database_eip" {
  type = string
}

variable "database_allocation_ip_id" {
    type = string
}

variable "ssh_pub_key_file_name" {
    type = string
}

variable "front_lb_id" {
  type = string
}

variable "back_lb_id" {
  type = string
}

variable "back_subnet_id" {
  type = string
}

variable "front_subnet_id" {
  type = string
}

variable "internet_gateway_id" {
  type = string
}

variable "vpc_id" {
  type = string
}