output "master_node_public_ip" {
  value = "${aws_instance.master_node.public_ip}"
}

# output "slave_node1_public_ip" {
#   value = "${aws_instance.slave_node1.public_ip}"
# }


