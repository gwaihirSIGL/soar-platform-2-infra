variable "gittoken" {
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
