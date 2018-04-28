output "vpc_subnet_front_id" {
  value = "${aws_subnet.front.id}"

}

output "vpc_subnet_back_id" {
  value = "${aws_subnet.back.id}"

}

