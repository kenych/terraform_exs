terraform {
  backend "s3" {

    bucket = "kayan-terra-state"
    key = "network/terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "my_ec2" {
  ami = "ami-a1f5e4c5"
  instance_type = "t2.micro"

  tags {
    Name = "example ec2"
  }

}


