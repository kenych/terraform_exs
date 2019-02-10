variable "region" {}

variable "vpc-cidr1" {}
variable "vpc-cidr2" {}

variable "subnet-site1" {
  type = "list"
}
variable "subnet-site2" {
  type = "list"
}

variable "availability_zones" {
  type = "list"
}


variable "component" {
  default = "vpn-network"
}
