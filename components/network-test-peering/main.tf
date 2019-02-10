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

# resource "aws_internet_gateway" "igw2" {
#   vpc_id = "${aws_vpc.vpc2.id}"

#   tags = {
#     Name = "${var.component}2"
#   }
# }

module "subnet_site1" {
  source             = "../../modules/subnets"
  component          = "${var.component}-site1"
  vpc_id             = "${aws_vpc.vpc1.id}"
  cidr_blocks        = "${var.subnet-site1}"
  gateway_id         = "${aws_internet_gateway.igw1.id}"
  availability_zones = "${var.availability_zones}"
}

module "subnet_site2" {
  source      = "../../modules/subnets"
  component   = "${var.component}-site2"
  vpc_id      = "${aws_vpc.vpc2.id}"
  cidr_blocks = "${var.subnet-site2}"
  is_public   = false

  # gateway_id         = "${aws_internet_gateway.igw2.id}"
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

  # associate_public_ip_address = true

  subnet_id = "${element(module.subnet_site2.subnet_ids, 0)}"

  instance_type = "t2.micro"
  key_name      = "terra"

  tags {
    Name = "test server2"
  }
}

# peering
module "vpc_peering_site1_to_site2" {
  source             = "../../modules/vpc-peering"
  source_vpc_id      = "${aws_vpc.vpc1.id}"
  destination_vpc_id = "${aws_vpc.vpc2.id}"
  auto_accept        = true

  source_subnets = ["${module.subnet_site1.subnet_ids}"]

  destination_subnets = "${module.subnet_site2.subnet_ids}"
}

# associate dns with peered vpc
# so curl nginx.zone1 from ec2 works
resource "aws_route53_zone" "zone1" {
  name = "zone1"

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

# s3 gw endpoint, ec2-2 in vpc2 can access even without internet access
# but only in curr region https://s3.eu-west-2.amazonaws.com/xxx
resource "aws_vpc_endpoint" "vpc-endpoint-vpc2" {
  vpc_id       = "${aws_vpc.vpc2.id}"
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "vpc-route-table-association" {
  vpc_endpoint_id = "${aws_vpc_endpoint.vpc-endpoint-vpc2.id}"
  route_table_id  = "${element(module.subnet_site2.route_table_ids, count.index)}"
}

