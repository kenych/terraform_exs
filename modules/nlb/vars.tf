variable "component" {}
variable "name" {}

variable "subnets" {
  type = "list"
}

variable "internal" {
  default = "false"
}

variable "lb_port" {}

variable "lb_protocol" {
  default = "TCP"
}

variable "vpc_id" {}

variable "asg_id" {
  default = ""
}

variable "instance_id" {
  default = ""
}

variable "instance_attach" {
  default = false
}
variable "asg_attach" {
  default = false
}

