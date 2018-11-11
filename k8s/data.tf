data "aws_caller_identity" "current" {}

data "aws_ami" "ubuntu_1604" {
  most_recent = true
  name_regex = "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-[0-9]*"
}

data "aws_vpc" "default" {
  tags {
    Name = "default"
  }
}

data "terraform_remote_state" "credstash" {
  backend = "s3"

  config {
    bucket = "kayan-terra-state"
    region = "eu-west-2"
    key    = "credstash.tfstate"
  }
}
