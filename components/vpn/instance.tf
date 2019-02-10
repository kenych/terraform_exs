provider "aws" {
  region = "${var.region}"
}

data "terraform_remote_state" "subnets" {
  backend = "s3"

  config {
    bucket = "kayan-terra-state"

    region = "${var.region}"
    key    = "component-vpn-network.tfstate"
  }
}

resource "aws_instance" "ec2_1" {
  ami = "ami-7c1bfd1b" //rhel

  associate_public_ip_address = true
  subnet_id                   = "${element(data.terraform_remote_state.subnets.subnet_site_id, 0)}"
  private_ip                  = "10.0.1.10"
  vpc_security_group_ids      = ["${aws_security_group.vpn_site.id}"]

  instance_type = "t2.micro"
  key_name      = "terra"

  user_data = "${file("ud-vpn.sh")}"

  tags {
    Name = "vpn server"
  }
}

resource "aws_instance" "ec2_2" {
  ami = "ami-7c1bfd1b" //rhel

  associate_public_ip_address = true
  subnet_id                   = "${element(data.terraform_remote_state.subnets.subnet_site_id, 0)}"
  private_ip                  = "10.0.1.20"
  vpc_security_group_ids      = ["${aws_security_group.vpn_site.id}"]

  instance_type = "t2.micro"
  key_name      = "terra"

  user_data = "${file("ud-server.sh")}"

  tags {
    Name = "web server"
  }
}

resource "aws_instance" "ec2_3" {
  ami = "ami-7c1bfd1b" //rhel

  associate_public_ip_address = true
  subnet_id                   = "${element(data.terraform_remote_state.subnets.subnet_client_id, 0)}"
  private_ip                  = "10.0.2.11"
  vpc_security_group_ids = ["${aws_security_group.vpn_client.id}"]


  instance_type = "t2.micro"
  key_name      = "terra"

  user_data = "${file("ud-vpn.sh")}"

  tags {
    Name = "vpn client"
  }
}

resource "aws_security_group" "vpn_site" {
  name   = "${var.component}-site"
  vpc_id = "${data.terraform_remote_state.subnets.vpc_id}"

  ingress = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["10.0.1.0/24"]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["10.8.0.0/24"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 1194
      to_port     = 1194
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

resource "aws_security_group" "vpn_client" {
  name   = "${var.component}-client"
  vpc_id = "${data.terraform_remote_state.subnets.vpc_id}"

  ingress = [
    {
      from_port   = 22
      to_port     = 22
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

output "vpn_server" {
  value = "${aws_instance.ec2_1.public_ip}"
}

output "web_server" {
  value = "${aws_instance.ec2_2.public_ip}"
}


output "vpn_client" {
  value = "${aws_instance.ec2_3.public_ip}"
}

