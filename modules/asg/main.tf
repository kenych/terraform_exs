resource "aws_autoscaling_group" "asg" {
  name             = "${var.component}"
  max_size         = "${var.max_size}"
  min_size         = "${var.min_size}"
  desired_capacity = "${var.desired_capacity}"

  launch_configuration = "${aws_launch_configuration.asg_lc.name}"
  load_balancers       = ["${var.load_balancer_ids}"]
  health_check_type    = "${var.health_check_type}"
  vpc_zone_identifier  = ["${var.subnets}"]

  tags = [
    {
      key                 = "Name"
      value               = "${var.component}"
      propagate_at_launch = true
    },
  ]

  tags = ["${var.tags}"]
}

resource "aws_launch_configuration" "asg_lc" {
  name_prefix                 = "${var.component}-lc-"
  image_id                    = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  user_data                   = "${var.user_data}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  security_groups             = ["${var.security_group_ids}"]

  root_block_device {
    volume_size = "${var.root_volume_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
