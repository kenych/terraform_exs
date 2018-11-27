resource "aws_instance" "etcd" {
  ami           = "${data.aws_ami.ubuntu_1604.id}"
  instance_type = "t2.micro"
  key_name      = "terra"
  user_data     = "${file("etcd.sh")}"
  availability_zone = "${var.availability_zone}"

  vpc_security_group_ids = [
    "${var.sg_id}",
  ]

  iam_instance_profile = "${var.iam_instance_profile}"

  tags {
    Name = "example etcd ${var.zone_suffix}"
  }
}

resource "aws_eip" "etcd" {
  instance = "${aws_instance.etcd.id}"
  vpc      = true
}

resource "aws_route53_record" "etcd" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name    = "etcd-${var.zone_suffix}.k8s.ifritltd.co.uk"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.etcd.public_ip}"]
}


