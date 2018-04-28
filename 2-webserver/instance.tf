provider "aws" {
  region = "eu-west-2"
}

variable "distros" {
  type = "map"

  default = {
    ubuntu = "ami-6b7f610f"
    rhel   = "ami-a1f5e4c5"
    amazon = "ami-e7d6c983"
  }
}

resource "aws_instance" "my_ec2" {
  //  amazon linux ami
  ami           = "${lookup(var.distros, "amazon")}"
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
  vpc_security_group_ids = [
    "${aws_security_group.web_app_sg.id}",
  ]

  tags {
    Name = "example ec2 with web app"
  }
}

variable "web_server_port" {
  description = "http port"
  default     = 80
}

resource "aws_security_group" "web_app_sg" {
  name = "web_app_sg"

  ingress {
    from_port = "${var.web_server_port}"
    to_port   = "${var.web_server_port}"
    protocol  = "tcp"

    cidr_blocks = [
      "${data.aws_ip_ranges.eu-west_regiions_ec2.cidr_blocks}",
    ]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

output "public_ip" {
  value = "${aws_instance.my_ec2.public_ip}"
}
