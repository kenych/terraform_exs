resource "aws_instance" "master_node" {
  ami           = "${data.aws_ami.ubuntu_1604.id}"
  instance_type = "t2.micro"
  key_name      = "terra"
  user_data     = "${file("userdata_master.sh")}"

  vpc_security_group_ids = [
    "${aws_security_group.kubernetes_sg.id}",
  ]

  iam_instance_profile = "${aws_iam_instance_profile.aws_iam_instance_profile.name}"

  tags {
    Name = "example k8s master"
  }
}

resource "aws_instance" "slave_node1" {
  ami           = "${data.aws_ami.ubuntu_1604.id}"
  instance_type = "t2.micro"
  key_name      = "terra"
  user_data     = "${file("userdata_node.sh")}"

  vpc_security_group_ids = [
    "${aws_security_group.kubernetes_sg.id}",
  ]

  iam_instance_profile = "${aws_iam_instance_profile.aws_iam_instance_profile.name}"

  tags {
    Name = "example k8s node1"
  }
}
