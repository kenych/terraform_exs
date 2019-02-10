variable "region" {}

variable "vpc-cidr" {}

variable "subnet-site" {
  type = "list"
}
variable "subnet-client" {
  type = "list"
}
variable "availability_zones" {
  type = "list"
}


variable "component" {
  default = "vpn-network"
}
