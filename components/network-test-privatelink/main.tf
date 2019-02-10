data "aws_region" "current" {}

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

  user_data = "${file("userdata.sh")}"

  tags {
    Name = "test server1"
  }

  vpc_security_group_ids = ["${aws_security_group.vpc-default-1.id}"]
}

resource "aws_instance" "ec2_2" {
  ami = "ami-7c1bfd1b" //rhel

  associate_public_ip_address = true

  subnet_id     = "${element(module.subnet_site2.subnet_ids, 0)}"
  instance_type = "t2.micro"
  key_name      = "terra"

  tags {
    Name = "test server2"
  }

  vpc_security_group_ids = ["${aws_security_group.vpc-default-2.id}"]
}

resource "aws_security_group" "vpc-default-1" {
  name = "${var.component}-vpc-default"

  vpc_id = "${aws_vpc.vpc1.id}"

  ingress = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vpc-default-2" {
  name = "${var.component}-vpc-default-2"

  vpc_id = "${aws_vpc.vpc2.id}"

  ingress = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "nlb" {
  source          = "../../modules/nlb"
  component       = "${var.component}"
  name            = "network-test-privatelink"
  subnets         = ["${element(module.subnet_site1.subnet_ids, 0)}"]
  lb_port         = 80
  vpc_id          = "${aws_vpc.vpc1.id}"
  internal        = true
  instance_id     = "${aws_instance.ec2_1.id}"
  instance_attach = true
}

resource "aws_vpc_endpoint_service" "vpce-service" {
  acceptance_required        = false
  network_load_balancer_arns = ["${module.nlb.arn}"]
}

resource "aws_vpc_endpoint" "vpc_endpoint" {
  vpc_id            = "${aws_vpc.vpc2.id}"
  service_name      = "${aws_vpc_endpoint_service.vpce-service.service_name}"
  subnet_ids        = ["${element(module.subnet_site2.subnet_ids, 0)}"]
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    "${aws_security_group.vpc-default-2.id}",
  ]
}

resource "aws_route53_zone" "zone2" {
  name = "zone2"

  vpc {
    vpc_id = "${aws_vpc.vpc2.id}"
  }

  lifecycle {
    ignore_changes = ["vpc"]
  }
}

resource "aws_route53_record" "vpc_endpoint_privatelink_dns" {
  zone_id    = "${aws_route53_zone.zone2.id}"
  name       = "http_test_vpc_endpoint"
  type       = "A"
  depends_on = ["aws_vpc_endpoint.vpc_endpoint"]

  alias {
    name                   = "${aws_vpc_endpoint.vpc_endpoint.dns_entry.0.dns_name}"
    zone_id                = "${aws_vpc_endpoint.vpc_endpoint.dns_entry.0.hosted_zone_id}"
    evaluate_target_health = false
  }
}
