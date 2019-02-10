variable "component" {}

variable "subnets" {
  type = "list"
}

variable "security_group_ids" {
  type = "list"
}

variable "max_size" {}

variable "min_size" {}

variable "desired_capacity" {}

variable "ami_id" {}

variable "key_name" {}

variable "instance_type" {}

variable "root_volume_size" {
  default = 16
}

variable "user_data" {
  default = "#"
}

variable "health_check_type" {
  default = "ELB"
}

variable "associate_public_ip_address" {
  default = "true"
}

variable "load_balancer_ids" {
  type    = "list"
  default = []
}

variable "tags" {
  type    = "list"
  default = []
}
