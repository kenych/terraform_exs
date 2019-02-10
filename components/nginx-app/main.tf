provider "aws" {
  region = "${var.region}"
}

data "aws_availability_zones" "all" {}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "subnets" {
  backend = "s3"

  config {
    bucket = "kayan-terra-state"

    region = "${var.region}"
    key    = "component-network-app.tfstate"
  }
}

data "terraform_remote_state" "bastion" {
  backend = "s3"

  config {
    bucket = "kayan-terra-state"

    region = "${var.region}"
    key    = "component-bastion.tfstate"
  }
}

module "asg" {
  source             = "../../modules/asg"
  component          = "${var.component}"
  subnets            = ["${data.terraform_remote_state.subnets.subnet_ids}"]
  security_group_ids = ["${aws_security_group.web-instance-security-group.id}"]

  max_size         = "${length(data.aws_availability_zones.all.names) * 2}"
  min_size         = "${length(data.aws_availability_zones.all.names)}"
  desired_capacity = "${length(data.aws_availability_zones.all.names)}"
  ami_id           = "${var.ami}"
  key_name           = "terra"
  instance_type    = "t2.small"

  user_data = "${data.template_file.userdata.rendered}"
}

data "template_file" "userdata" {
  template = "${file("userdata.tpl")}"

  vars {
    app_name    = "${var.app_name}"
    app_version = "${var.app_version}"
  }
}

module "nlb" {
  source    = "../../modules/nlb"
  component = "${var.component}"
  subnets   = ["${data.terraform_remote_state.subnets.subnet_ids}"]
  lb_port   = 80
  vpc_id    = "${data.terraform_remote_state.subnets.vpc_id}"
  asg_id    = "${module.asg.asg_id}"
}

resource "aws_security_group" "web-instance-security-group" {
  name   = "${var.component}-security-group"
  vpc_id = "${data.terraform_remote_state.subnets.vpc_id}"

  ingress = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      security_groups = ["${data.terraform_remote_state.bastion.sg_id}"]
    },
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "web_domain" {
  value = "${module.nlb.dns_name}"
}
