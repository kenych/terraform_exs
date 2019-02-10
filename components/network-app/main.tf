data "aws_availability_zones" "all" {}

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
}

module "subnets" {
  source             = "../../modules/subnets"
  component          = "${var.component}"
  vpc_id             = "${aws_vpc.vpc.id}"
  cidr_blocks        = "${var.subnet-cidr-public}"
  gateway_id         = "${aws_internet_gateway.igw.id}"
  availability_zones = "${data.aws_availability_zones.all.names}"
}

# We should provision PKI infra within its own component, but just for convenience we will just keep it here as network will be dependency 
# for all other components. Ideally keys should be privisioned dynamically through configuration in sshd, so when we try to login, our key is fetched from IAM dynamically.
resource "aws_key_pair" "web" {
  public_key = "${file(pathexpand(var.public_key))}"
}
