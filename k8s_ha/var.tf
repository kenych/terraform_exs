
variable "component" {
  default = "kubernetes_master"
}


variable "instance_type" {
  default = "t2.medium"
}

variable "context_key" {
  default = "role"
}

variable "context_value" {
  default = "kubernetes"
}


variable "instances" {
  default = "1"
}


variable "listener_port" {
  default = 6443
}

variable "listener_protocol" {
  default = "TCP"
}

variable "lb_port" {
  default = 6443
}

variable "lb_protocol" {
  default = "TCP"
}

variable "hc_target" {
  default = "TCP:6443"
}

variable "hc_healthy_threshold" {
  default = 3
}

variable "hc_unhealthy_threshold" {
  default = 3
}

variable "hc_timeout" {
  default = 5
}

variable "hc_interval" {
  default = 30
}

variable "hc_port" {
  default = 6443
}

variable "hc_protocol" {
  default = "TCP"
}

variable "enable_cross_zone_load_balancing" {
  default = "true"
}

