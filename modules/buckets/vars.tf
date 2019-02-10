variable "bucket_name" {}

variable "acl" {
  default = "private"
}

variable "region" {}

variable "versioning" {
  default = false
}
