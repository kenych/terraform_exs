provider "aws" {
  //replace with VAULT or
  //  export AWS_ACCESS_KEY_ID=xx
  //  export AWS_SECRET_ACCESS_KEY=yyy

  //  access_key = "**"
  //  secret_key = "**"
  region = "eu-west-2"
}

resource "aws_instance" "my_ec2" {
  ami = "ami-a1f5e4c5"
  instance_type = "t2.micro"

  tags {
    Name = "example ec2"
  }

}


