//requires 5-vpc

resource "aws_instance" "front_ec2" {
  ami           = "ami-a1f5e4c5"
  instance_type = "t2.micro"
  subnet_id     = "${data.terraform_remote_state.vpc.vpc_subnet_front_id}"

  tags {
    Name = "example ec2 front"
  }
}

resource "aws_instance" "back_ec2" {
  ami           = "ami-a1f5e4c5"
  instance_type = "t2.micro"
  subnet_id     = "${data.terraform_remote_state.vpc.vpc_subnet_back_id}"

  tags {
    Name = "example ec2 back"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "kayan-terra-state"
    key    = "dev/vpc/terraform.tfstate"
    region = "eu-west-2"
  }
}
