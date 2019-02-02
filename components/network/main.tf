
provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc-cidr}"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.component}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "${var.component}"
  }
}

module "subnet_site" {
  source             = "../../modules/subnets"
  component          = "${var.component}-site"
  vpc_id             = "${aws_vpc.vpc.id}"
  cidr_blocks        = "${var.subnet-site}"
  gateway_id         = "${aws_internet_gateway.igw.id}"
  availability_zones = "${var.availability_zones}"
}
module "subnet_client" {
  source             = "../../modules/subnets"
  component          = "${var.component}-client"
  vpc_id             = "${aws_vpc.vpc.id}"
  cidr_blocks        = "${var.subnet-client}"
  gateway_id         = "${aws_internet_gateway.igw.id}"
  availability_zones = "${var.availability_zones}"
}


