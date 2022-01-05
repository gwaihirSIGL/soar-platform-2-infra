variable "gittoken" {
  type = string
}

variable "database_hostname" {
  type        = string
}

variable "database_user" {
  type        = string
}

# Careful ! This password is respecting the following policy:
# 8+ characters
# include mixed case
# include number
# include special character
variable "database_password" {
  type        = string
}

variable "subnet_id_for_image_build" {
  type        = string
}

variable "allow_ssh_sec_group_id" {
  type        = string
}
variable "allow_outbound_sec_group_id" {
  type        = string
}

variable "ami_name" {
  type    = string
  default = "backend-ami"
}

variable "region" {
  type    = string
  default = "eu-west-3"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

data "amazon-ami" "amazon-kernel-ami" {
  filters = {
    virtualization-type = "hvm"
    name                = "amzn2-ami-kernel-5.10*"
    root-device-type    = "ebs"
  }
  owners      = ["amazon"]
  most_recent = true
  region        = "${var.region}"
}

source "amazon-ebs" "ssm" {
  ami_name      = "${var.ami_name}-${local.timestamp}"
  ami_virtualization_type = "hvm"
  instance_type = "t2.micro"
  source_ami           = data.amazon-ami.amazon-kernel-ami.id

  communicator = "ssh"
  ssh_username = "ec2-user"
  ssh_interface = "session_manager"
  ssh_timeout = "1h"

  region        = "${var.region}"
  subnet_id = "${var.subnet_id_for_image_build}"
  security_group_ids = [
    "${var.allow_ssh_sec_group_id}",
    "${var.allow_outbound_sec_group_id}",
  ]

  aws_polling {
    delay_seconds = 15
    max_attempts = 30
  }

  temporary_iam_instance_profile_policy_document {
      Statement {
          Action   = [
            "logs:*",
            "ssm:*",
          ]
          Effect   = "Allow"
          Resource = ["*"]
      }
      Version = "2012-10-17"
  }
}

build {
  sources = ["source.amazon-ebs.ssm"]
  # install dependancies
  provisioner "shell" {
    inline = [
      "yum update",
      "yum install -y git",
      "curl --silent --location https://rpm.nodesource.com/setup_12.x | sudo bash - && sudo yum -y install nodejs"
    ]
  }
  # install application
  provisioner "shell" {
    inline = [
      "mkdir -p /app",
      "cd /app",
      "git clone https://${var.gittoken}@github.com/gwaihirSIGL/soar-platform-2-back.git",
      "cd soar-platform-2-back",
      "npm i",
      "echo \"PGHOST='${var.database_hostname}'\" >> .env",
      "echo \"POSTGRES_USER='${var.database_user}'\" >> .env",
      "echo \"POSTGRES_PASSWORD='${var.database_password}'\" >> .env",
      "echo \"POSTGRES_DB=soar\" >> .env",
      "echo \"POSTGRES_PORT=3306\" >> .env",
      "echo \"PORT=4002\" >> .env",
    ]
  }
}