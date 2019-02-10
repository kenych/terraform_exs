variable "region" {}

variable "vpc-cidr" {}

variable "subnet-cidr-public" {
  type = "list"
}

variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "component" {
  default = "network-app"
}
