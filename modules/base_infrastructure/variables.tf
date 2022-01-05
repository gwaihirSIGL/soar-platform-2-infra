variable "vpc_name" {
  type = string
  default = "soar_platform_2"
}

variable "region" {
  type = string
  default = "eu-west-3"
}

variable "availability_zone_1" {
  type = string
  default = "eu-west-3c"
}

variable "ssh_pub_key_file_name" {
  type = string
  default = "soar_ssh_key"
}

variable "ssh_pub_key_file_path" {
  type = string
  default = "./soar-key.pub"
}

variable "subnet_for_image_build_cidr_block" {
  type = string
  default = "192.168.30.0/24"
}
