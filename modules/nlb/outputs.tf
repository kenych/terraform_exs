output "dns_name" {
  value = "${aws_lb.load_balancer.dns_name}"
}
output "id" {
  value = "${aws_lb.load_balancer.id}"
}
output "arn" {
  value = "${aws_lb.load_balancer.arn}"
}
