resource "aws_elb" "api_load_balancer" {
  name = "k8s-api"

  #   subnets  = ["${var.subnets}"]
  internal = true

  subnets = ["subnet-4e89bb03", "subnet-52ce2228","subnet-892a81e0" ]
#   subnets = ["subnet-4e89bb03", "subnet-52ce2228","subnet-892a81e0", ]

#   instances = ["${aws_instance.master_node1.id}", "${aws_instance.master_node2.id}", "${aws_instance.master_node3.id}"]
  instances = ["${aws_instance.master_node1.id}", "${aws_instance.master_node2.id}"]

  listener {
    instance_port     = "${var.listener_port}"
    instance_protocol = "${var.lb_protocol}"
    lb_port           = "${var.lb_port}"
    lb_protocol       = "${var.lb_protocol}"
  }

  health_check {
    interval            = "${var.hc_interval}"
    healthy_threshold   = "${var.hc_healthy_threshold}"
    unhealthy_threshold = "${var.hc_unhealthy_threshold}"
    target              = "${var.hc_target}"
    timeout             = "${var.hc_timeout}"
  }

  security_groups = ["${aws_security_group.kubernetes_sg.id}"]

  tags = [
    {
      key   = "KubernetesCluster"
      value = "kubernetes"
    },
  ]
}

data "aws_route53_zone" "k8s_zone" {
  name         = "k8s.ifritltd.co.uk."
  private_zone = true
}

resource "aws_route53_record" "kubernetes" {
  name    = "kubernetes"
  type    = "A"
  zone_id = "${data.aws_route53_zone.k8s_zone.zone_id}"

  alias {
    name                   = "${aws_elb.api_load_balancer.dns_name}"
    zone_id                = "${aws_elb.api_load_balancer.zone_id}"
    evaluate_target_health = false
  }
}
