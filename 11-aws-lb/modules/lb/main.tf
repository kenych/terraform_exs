resource "aws_lb" "test" {
  name               = "${var.name}"
  load_balancer_type = "network"
  internal = "${var.internal}"

  enable_deletion_protection = false
  subnet_mapping {
    subnet_id     = "subnet-4e89bb03"
    allocation_id = "${var.eip}"
  }

  enable_deletion_protection = true
  tags {
    Environment = "terra-11-aws-lb"
  }

}