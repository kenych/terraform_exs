variable "source_vpc_id" {}

variable "destination_vpc_id" {}

variable "auto_accept" {}

variable "source_subnets" {
  type = "list"
}

variable "destination_subnets" {
  type = "list"
}