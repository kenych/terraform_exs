resource "aws_security_group" "kubernetes_sg" {
  name        = "k8s_sg"
  description = "k8s_sg"
  vpc_id      = "${data.aws_vpc.default.id}"
}

resource "aws_security_group_rule" "all-master-to-master" {
  type              = "ingress"
  security_group_id = "${aws_security_group.kubernetes_sg.id}"
  self              = true
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

resource "aws_security_group_rule" "allow_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.kubernetes_sg.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.kubernetes_sg.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}
