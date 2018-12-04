resource "aws_instance" "master_node1" {
  ami           = "${data.aws_ami.ubuntu_1604.id}"
  instance_type = "t2.micro"
  key_name      = "terra"
  user_data     = "${file("userdata_master_init.sh")}"

  vpc_security_group_ids = [
    "${aws_security_group.kubernetes_sg.id}",
  ]

  availability_zone    = "eu-west-2a"
  iam_instance_profile = "${aws_iam_instance_profile.aws_iam_instance_profile.name}"

  tags {
    Name = "example k8s master1"
  }
}

resource "aws_instance" "master_node2" {
  ami           = "${data.aws_ami.ubuntu_1604.id}"
  instance_type = "t2.micro"
  key_name      = "terra"
  user_data     = "${file("userdata_master_join.sh")}"

  vpc_security_group_ids = [
    "${aws_security_group.kubernetes_sg.id}",
  ]

  availability_zone    = "eu-west-2b"
  iam_instance_profile = "${aws_iam_instance_profile.aws_iam_instance_profile.name}"

  tags {
    Name = "example k8s master2"
  }
}


