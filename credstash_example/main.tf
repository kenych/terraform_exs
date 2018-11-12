resource "aws_instance" "credstash_admin" {
  ami           = "${data.aws_ami.ubuntu_1604.id}"
  instance_type = "t2.micro"

  key_name  = "terra"
  user_data = "${file("setup.sh")}"

  vpc_security_group_ids = [
    "${aws_security_group.sg.id}",
  ]

  iam_instance_profile = "${aws_iam_instance_profile.aws_iam_instance_profile_admin.name}"

  tags {
    Name = "example credstash admin"
  }
}

resource "aws_instance" "credstash_dev" {
  ami           = "${data.aws_ami.ubuntu_1604.id}"
  instance_type = "t2.micro"

  key_name  = "terra"
  user_data = "${file("setup.sh")}"

  vpc_security_group_ids = [
    "${aws_security_group.sg.id}",
  ]

  iam_instance_profile = "${aws_iam_instance_profile.aws_iam_instance_profile_dev.name}"

  tags {
    Name = "example credstash dev"
  }
}

resource "aws_instance" "credstash_qa" {
  ami           = "${data.aws_ami.ubuntu_1604.id}"
  instance_type = "t2.micro"

  key_name  = "terra"
  user_data = "${file("setup.sh")}"

  vpc_security_group_ids = [
    "${aws_security_group.sg.id}",
  ]

  iam_instance_profile = "${aws_iam_instance_profile.aws_iam_instance_profile_qa.name}"

  tags {
    Name = "example credstash qa"
  }
}
