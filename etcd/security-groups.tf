resource "aws_security_group" "etcd" {
  name        = "etcd_sg"
  description = "etcd_sg"
  vpc_id      = "${data.aws_vpc.default.id}"
}

resource "aws_security_group_rule" "all-internal" {
  type              = "ingress"
  security_group_id = "${aws_security_group.etcd.id}"
  self              = true
  from_port         = 2379
  to_port           = 2380
  protocol          = "tcp"
}

resource "aws_security_group_rule" "allow_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.etcd.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}
# temp for k8s
resource "aws_security_group_rule" "allow_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.etcd.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

# resource "aws_security_group_rule" "allow_ssh" {
#   type        = "ingress"
#   from_port   = 22
#   to_port     = 22
#   protocol    = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]

#   security_group_id = "${aws_security_group.etcd.id}"
# }
