variable "component" {}

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

variable "asg_id" {}
