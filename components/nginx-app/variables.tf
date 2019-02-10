variable "region" {}

variable "ami" {
  default = "ami-b61305d2"
}

variable "component" {
  default = "nginx"
}

variable "app_name" {
  default = "gs-spring-boot"
}

variable "app_version" {
  default = "0.1.0"
}
