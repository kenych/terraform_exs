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

module "asg" {
  source             = "../../modules/asg"
  component          = "${var.component}"
  subnets            = ["${data.terraform_remote_state.subnets.subnet_ids}"]
  security_group_ids = ["${aws_security_group.bastion-instance-security-group.id}"]
  key_name           = "terra"

  max_size         = "1"
  min_size         = "1"
  desired_capacity = "1"
  ami_id           = "${var.ami}"
  instance_type    = "t2.small"
}

# dont' use inline rules as this is dependency for other components and it won't be 
# possible to edit unless dependants destroyed first
resource "aws_security_group" "bastion-instance-security-group" {
  name   = "${var.component}-security-group"
  vpc_id = "${data.terraform_remote_state.subnets.vpc_id}"
}

resource "aws_security_group_rule" "bastion-instance-security-group_rule_ingress_ssh" {
  security_group_id = "${aws_security_group.bastion-instance-security-group.id}"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  description       = "ssh ingress all"
}

resource "aws_security_group_rule" "bastion-instance-security-group_rule_egress_ssh" {
  security_group_id = "${aws_security_group.bastion-instance-security-group.id}"
  type              = "egress"
  cidr_blocks       = ["${data.terraform_remote_state.subnets.vpc_cidr}"]
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  description       = "ssh egress vpc"
}
