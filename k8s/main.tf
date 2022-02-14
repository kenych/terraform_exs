resource "aws_instance" "master_node" {
  ami           = "${data.aws_ami.ubuntu_1604.id}"
  instance_type = "t2.large"
  key_name      = "${aws_key_pair.generated_key.key_name}"
  user_data     = "${file("userdata_master.sh")}"

  vpc_security_group_ids = [
    "${aws_security_group.kubernetes_sg.id}",
  ]

  iam_instance_profile = "${aws_iam_instance_profile.aws_iam_instance_profile.name}"

  tags {
    Name = "example k8s master"
  }
}

provider "aws" {
  region = "eu-west-2"
  version = "v2.70.0"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "terra"
  public_key = "${tls_private_key.private_key.public_key_openssh}"
}

# uncomment for enable slave nodes:
# otherwise run as single node cluster similar to minikube
# resource "aws_instance" "slave_node1" {
#   ami           = "${data.aws_ami.ubuntu_1604.id}"
#   instance_type = "t2.micro"
#   key_name      = "terra"
#   user_data     = "${file("userdata_node.sh")}"

#   vpc_security_group_ids = [
#     "${aws_security_group.kubernetes_sg.id}",
#   ]

#   iam_instance_profile = "${aws_iam_instance_profile.aws_iam_instance_profile.name}"

#   tags {
#     Name = "example k8s node1"
#   }
# }
