output "admin_ip" {
  value = "${aws_instance.credstash_admin.public_ip}"
}
output "dev_ip" {
  value = "${aws_instance.credstash_dev.public_ip}"
}
output "qa_ip" {
  value = "${aws_instance.credstash_qa.public_ip}"
}


