output "name" {
  value = "${aws_autoscaling_group.asg.name}"
}

output "asg_id" {
  value = "${aws_autoscaling_group.asg.id}"
}
