resource "aws_vpc" "dev" {
  cidr_block = "10.0.0.0/18"

  tags {
    Name = "${var.tag-name}"
  }
}

resource "aws_subnet" "front" {
  vpc_id            = "${aws_vpc.dev.id}"
  availability_zone = "eu-west-2a"
  cidr_block        = "10.0.0.0/24"

  tags {
    Name = "${var.tag-name}-front"
  }
}

resource "aws_subnet" "back" {
  vpc_id            = "${aws_vpc.dev.id}"
  availability_zone = "eu-west-2b"
  cidr_block        = "10.0.1.0/24"

  tags {
    Name = "${var.tag-name}-back"
  }
}
