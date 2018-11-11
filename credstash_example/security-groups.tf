resource "aws_security_group" "sg" {
  name        = "credstash_reader_sg"
  vpc_id      = "vpc-5b3efd33"
}

resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.sg.id}"
  cidr_blocks       = ["0.0.0.0/0"]

}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  # change this to your IP address
  cidr_blocks     = ["92.4.52.251/32"]

  security_group_id = "${aws_security_group.sg.id}"
}
