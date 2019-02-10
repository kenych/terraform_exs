output "subnet_ids" {
  value = ["${module.subnets.subnet_ids}"]
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "key_name" {
  value = "${aws_key_pair.web.key_name}"
}
