provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "vpc1" {
  cidr_block           = "${var.vpc-cidr1}"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.component}-1"
  }
}

resource "aws_vpc" "vpc2" {
  cidr_block           = "${var.vpc-cidr2}"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.component}-2"
  }
}

resource "aws_internet_gateway" "igw1" {
  vpc_id = "${aws_vpc.vpc1.id}"

  tags = {
    Name = "${var.component}1"
  }
}

resource "aws_internet_gateway" "igw2" {
  vpc_id = "${aws_vpc.vpc2.id}"

  tags = {
    Name = "${var.component}2"
  }
}

module "subnet_site1" {
  source             = "../../modules/subnets"
  component          = "${var.component}-site1"
  vpc_id             = "${aws_vpc.vpc1.id}"
  cidr_blocks        = "${var.subnet-site1}"
  gateway_id         = "${aws_internet_gateway.igw1.id}"
  availability_zones = "${var.availability_zones}"
}

module "subnet_site2" {
  source             = "../../modules/subnets"
  component          = "${var.component}-site2"
  vpc_id             = "${aws_vpc.vpc2.id}"
  cidr_blocks        = "${var.subnet-site2}"
  gateway_id         = "${aws_internet_gateway.igw2.id}"
  availability_zones = "${var.availability_zones}"
}

resource "aws_instance" "ec2_1" {
  ami = "ami-7c1bfd1b" //rhel

  associate_public_ip_address = true

  subnet_id = "${element(module.subnet_site1.subnet_ids, 0)}"

  instance_type = "t2.micro"
  key_name      = "terra"

  tags {
    Name = "test server1"
  }
}
resource "aws_instance" "ec2_2" {
  ami = "ami-7c1bfd1b" //rhel

  associate_public_ip_address = true

  subnet_id = "${element(module.subnet_site2.subnet_ids, 0)}"

  instance_type = "t2.micro"
  key_name      = "terra"

  tags {
    Name = "test server2"
  }
}


module "vpc_peering_site1_to_site2" {
  source             = "../../modules/vpc-peering"
  source_vpc_id      = "${aws_vpc.vpc1.id}"
  destination_vpc_id = "${aws_vpc.vpc2.id}"
  auto_accept        = true

  source_subnets = ["${module.subnet_site1.subnet_ids}"]

  destination_subnets = "${module.subnet_site2.subnet_ids}"

}



resource "aws_route53_zone" "zone1" {
  name   = "zone1"
  vpc {
    vpc_id = "${aws_vpc.vpc1.id}"
  }

  lifecycle {
    ignore_changes = ["vpc"]
  }
  
}

resource "aws_route53_record" "zone1" {
  zone_id = "${aws_route53_zone.zone1.zone_id}"
  name    = "nginx"
  type    = "A"
  ttl     = "30"
  records = ["${aws_instance.ec2_1.private_ip}"]
}

resource "aws_route53_zone_association" "zone1-vpc2" {
  zone_id = "${aws_route53_zone.zone1.zone_id}"
  vpc_id  = "${aws_vpc.vpc2.id}"
}
