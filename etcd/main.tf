module "etcd-a" {
  source               = "module/etcd"
  availability_zone    = "eu-west-2a"
  zone_suffix          = "a"
  iam_instance_profile = "${aws_iam_instance_profile.aws_iam_instance_profile.name}"
  sg_id                = "${aws_security_group.etcd.id}"
  zone_id              = "${aws_route53_zone.k8s_private_zone.zone_id}"
}

module "etcd-b" {
  source               = "module/etcd"
  availability_zone    = "eu-west-2b"
  zone_suffix          = "b"
  iam_instance_profile = "${aws_iam_instance_profile.aws_iam_instance_profile.name}"
  sg_id                = "${aws_security_group.etcd.id}"
  zone_id              = "${aws_route53_zone.k8s_private_zone.zone_id}"
}

module "etcd-c" {
  source               = "module/etcd"
  availability_zone    = "eu-west-2c"
  zone_suffix          = "c"
  iam_instance_profile = "${aws_iam_instance_profile.aws_iam_instance_profile.name}"
  sg_id                = "${aws_security_group.etcd.id}"
  zone_id              = "${aws_route53_zone.k8s_private_zone.zone_id}"
}

resource "aws_route53_zone" "k8s_private_zone" {
  name = "k8s.ifritltd.co.uk"

  vpc {
    vpc_id = "${data.aws_vpc.default.id}"
  }
}
