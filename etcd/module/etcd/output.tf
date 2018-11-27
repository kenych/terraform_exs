output "public_ip" {
  value = "${aws_instance.etcd.public_ip}"
}

