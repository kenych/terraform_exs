output "etcd-a" {
  value = "${module.etcd-a.public_ip}"
}

output "etcd-b" {
  value = "${module.etcd-b.public_ip}"
}

output "etcd-c" {
  value = "${module.etcd-c.public_ip}"
}
