provider "aws" {
  region = "${var.region}"
}

data "aws_caller_identity" "current" {}

# module "buckets" {
#   source      = "../../modules/buckets"
#   region      = "${var.region}"
#   versioning  = "true"
#   bucket_name = "terraform-${data.aws_caller_identity.current.account_id}-${var.region}"
# }

# module "buckets1" {
#   source      = "../../modules/buckets"
#   region      = "${var.region}"
#   versioning  = "true"
#   bucket_name = "testing-gw"
#   acl         = "public-read"
# }

variable "region" {
  default = "eu-west-2"
}
