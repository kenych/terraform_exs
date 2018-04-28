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

resource "aws_instance" "my_ec2_2" {
  //  amazon linux ami
  ami           = "${lookup(var.distros, "amazon")}"
  instance_type = "t2.micro"

  key_name = "terra"

  user_data = <<-EOF
    #cloud-config
    repo_update: true
    repo_upgrade: all

    packages:
     - httpd24
     - php56
     - mysql55-server
     - php56-mysqlnd

    runcmd:
     - service httpd start
     - chkconfig httpd on
     - groupadd www
     - [ sh, -c, "usermod -a -G www ec2-user" ]
     - [ sh, -c, "chown -R root:www /var/www" ]
     - chmod 2775 /var/www
     - [ find, /var/www, -type, d, -exec, chmod, 2775, {}, + ]
     - [ find, /var/www, -type, f, -exec, chmod, 0664, {}, + ]
     - [ sh, -c, 'echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php' ]
    EOF

  //  implicit dep
  vpc_security_group_ids = [
    "${aws_security_group.web_app_sg.id}",
  ]

  tags {
    Name = "example ec2 with web app and cloud init"
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
