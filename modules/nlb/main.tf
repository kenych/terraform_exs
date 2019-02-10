resource "aws_lb" "load_balancer" {
  name     = "${var.name}"
  internal = "${var.internal}"

  load_balancer_type = "network"

  subnets = ["${var.subnets}"]
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = "${aws_lb.load_balancer.arn}"
  port              = "${var.lb_port}"
  protocol          = "${var.lb_protocol}"

  default_action {
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "target_group" {
  name     = "${var.name}"
  port     = "${var.lb_port}"
  protocol = "${var.lb_protocol}"
  vpc_id   = "${var.vpc_id}"

  # need to provide empty as otherwise fails, due to sharing this property with alb
  # https://github.com/terraform-providers/terraform-provider-aws/issues/2746
  stickiness = []

  # create then delete as otherwise would fail with 'is currently inuse by a listener or a rule'
  lifecycle {
    create_before_destroy = true
  }


}

resource "aws_autoscaling_attachment" "asg_attach" {
  count = "${var.asg_attach  ? 1 : 0}"

  autoscaling_group_name = "${var.asg_id}"
  alb_target_group_arn   = "${aws_lb_target_group.target_group.arn}"
}

resource "aws_lb_target_group_attachment" "instance_attach" {

  count = "${var.instance_attach ? 1 : 0}"
  target_group_arn = "${aws_lb_target_group.target_group.arn}"
  target_id        = "${var.instance_id}"
  port             = "${var.lb_port}"
}