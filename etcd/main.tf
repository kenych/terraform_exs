module "etcd-a" {
  source               = "module/etcd"
  availability_zone    = "eu-west-2a"
  zone_suffix          = "a"
  iam_instance_profile = "${aws_iam_instance_profile.aws_iam_instance_profile.name}"
  sg_id                = "${aws_security_group.etcd.id}"
}

module "etcd-b" {
  source               = "module/etcd"
  availability_zone    = "eu-west-2b"
  zone_suffix          = "b"
  iam_instance_profile = "${aws_iam_instance_profile.aws_iam_instance_profile.name}"
  sg_id                = "${aws_security_group.etcd.id}"
}

module "etcd-c" {
  source               = "module/etcd"
  availability_zone    = "eu-west-2c"
  zone_suffix          = "c"
  iam_instance_profile = "${aws_iam_instance_profile.aws_iam_instance_profile.name}"
  sg_id                = "${aws_security_group.etcd.id}"
}

