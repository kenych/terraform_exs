output "master1_node_public_ip" {
  value = "${aws_instance.master_node1.public_ip}"
}
output "master2_node_public_ip" {
  value = "${aws_instance.master_node2.public_ip}"
}
output "master3_node_public_ip" {
  value = "${aws_instance.master_node3.public_ip}"
}

output "slave_node1_node_public_ip" {
  value = "${aws_instance.slave_node1.public_ip}"
}

output "slave_node2_node_public_ip" {
  value = "${aws_instance.slave_node2.public_ip}"
}

output "slave_node3_node_public_ip" {
  value = "${aws_instance.slave_node3.public_ip}"
}
