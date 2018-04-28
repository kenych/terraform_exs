provider "aws" {
  region = "eu-west-2"
}

data "aws_availability_zones" "all" {}

variable "distros" {
  type = "map"

  default = {
    ubuntu = "ami-6b7f610f"
    rhel   = "ami-a1f5e4c5"
    amazon = "ami-e7d6c983"
  }
}

resource "aws_launch_configuration" "my_ec2_asg_lc" {
  //  amazon linux ami
  image_id      = "${lookup(var.distros, "amazon")}"
  instance_type = "t2.micro"

  key_name = "terra"

  user_data = <<-EOF
    #!/bin/bash

    yum update -y
    yum install httpd -y
    service httpd start
    chkconfig httpd on
    echo "hello world" > /var/www/html/index.html
    EOF

  //  implicit dep
  security_groups = [
    "${aws_security_group.web_app_sg.id}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

variable "web_server_port" {
  description = "http port"
  default     = 80
}

resource "aws_security_group" "web_app_sg" {
  name = "web_app_sg"

  //www
  ingress {
    from_port = "${var.web_server_port}"
    to_port   = "${var.web_server_port}"
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  //ssh
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  //  for yum update etc
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "web_app_elb_sg" {
  name = "web_app_elb_sg"

  //  to accept req from www
  ingress {
    from_port = "${var.web_server_port}"
    to_port   = "${var.web_server_port}"
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  //  to send req to web app
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "my_ec2_asg" {
  launch_configuration = "${aws_launch_configuration.my_ec2_asg_lc.id}"

  availability_zones = [
    "${data.aws_availability_zones.all.names}",
  ]

  min_size = 2
  max_size = 5

  load_balancers    = ["${aws_elb.webappelb.name}"]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "asg by terraform"
    propagate_at_launch = true
  }
}

resource "aws_elb" "webappelb" {
  name = "webappelb"

  availability_zones = [
    "${data.aws_availability_zones.all.names}",
  ]

  security_groups = ["${aws_security_group.web_app_elb_sg.id}"]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.web_server_port}"
    instance_protocol = "http"
  }
}

output "elb_dns_name" {
  value = "${aws_elb.webappelb.dns_name}"
}
