output "cluster_name" {
  value = "k8s.ifritltd.co.uk"
}

output "master_security_group_ids" {
  value = ["${aws_security_group.masters-k8s-ifritltd-co-uk.id}"]
}

output "masters_role_arn" {
  value = "${aws_iam_role.masters-k8s-ifritltd-co-uk.arn}"
}

output "masters_role_name" {
  value = "${aws_iam_role.masters-k8s-ifritltd-co-uk.name}"
}

output "node_security_group_ids" {
  value = ["${aws_security_group.nodes-k8s-ifritltd-co-uk.id}"]
}

output "node_subnet_ids" {
  value = ["${aws_subnet.eu-west-2a-k8s-ifritltd-co-uk.id}"]
}

output "nodes_role_arn" {
  value = "${aws_iam_role.nodes-k8s-ifritltd-co-uk.arn}"
}

output "nodes_role_name" {
  value = "${aws_iam_role.nodes-k8s-ifritltd-co-uk.name}"
}

output "region" {
  value = "eu-west-2"
}

output "vpc_id" {
  value = "${aws_vpc.k8s-ifritltd-co-uk.id}"
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_autoscaling_group" "master-eu-west-2a-masters-k8s-ifritltd-co-uk" {
  name                 = "master-eu-west-2a.masters.k8s.ifritltd.co.uk"
  launch_configuration = "${aws_launch_configuration.master-eu-west-2a-masters-k8s-ifritltd-co-uk.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.eu-west-2a-k8s-ifritltd-co-uk.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "k8s.ifritltd.co.uk"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-eu-west-2a.masters.k8s.ifritltd.co.uk"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-eu-west-2a"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_autoscaling_group" "nodes-k8s-ifritltd-co-uk" {
  name                 = "nodes.k8s.ifritltd.co.uk"
  launch_configuration = "${aws_launch_configuration.nodes-k8s-ifritltd-co-uk.id}"
  max_size             = 2
  min_size             = 2
  vpc_zone_identifier  = ["${aws_subnet.eu-west-2a-k8s-ifritltd-co-uk.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "k8s.ifritltd.co.uk"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.k8s.ifritltd.co.uk"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "nodes"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_ebs_volume" "a-etcd-events-k8s-ifritltd-co-uk" {
  availability_zone = "eu-west-2a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                          = "k8s.ifritltd.co.uk"
    Name                                       = "a.etcd-events.k8s.ifritltd.co.uk"
    "k8s.io/etcd/events"                       = "a/a"
    "k8s.io/role/master"                       = "1"
    "kubernetes.io/cluster/k8s.ifritltd.co.uk" = "owned"
  }
}

resource "aws_ebs_volume" "a-etcd-main-k8s-ifritltd-co-uk" {
  availability_zone = "eu-west-2a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                          = "k8s.ifritltd.co.uk"
    Name                                       = "a.etcd-main.k8s.ifritltd.co.uk"
    "k8s.io/etcd/main"                         = "a/a"
    "k8s.io/role/master"                       = "1"
    "kubernetes.io/cluster/k8s.ifritltd.co.uk" = "owned"
  }
}

resource "aws_iam_instance_profile" "masters-k8s-ifritltd-co-uk" {
  name = "masters.k8s.ifritltd.co.uk"
  role = "${aws_iam_role.masters-k8s-ifritltd-co-uk.name}"
}

resource "aws_iam_instance_profile" "nodes-k8s-ifritltd-co-uk" {
  name = "nodes.k8s.ifritltd.co.uk"
  role = "${aws_iam_role.nodes-k8s-ifritltd-co-uk.name}"
}

resource "aws_iam_role" "masters-k8s-ifritltd-co-uk" {
  name               = "masters.k8s.ifritltd.co.uk"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.k8s.ifritltd.co.uk_policy")}"
}

resource "aws_iam_role" "nodes-k8s-ifritltd-co-uk" {
  name               = "nodes.k8s.ifritltd.co.uk"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.k8s.ifritltd.co.uk_policy")}"
}

resource "aws_iam_role_policy" "masters-k8s-ifritltd-co-uk" {
  name   = "masters.k8s.ifritltd.co.uk"
  role   = "${aws_iam_role.masters-k8s-ifritltd-co-uk.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters.k8s.ifritltd.co.uk_policy")}"
}

resource "aws_iam_role_policy" "nodes-k8s-ifritltd-co-uk" {
  name   = "nodes.k8s.ifritltd.co.uk"
  role   = "${aws_iam_role.nodes-k8s-ifritltd-co-uk.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes.k8s.ifritltd.co.uk_policy")}"
}

resource "aws_internet_gateway" "k8s-ifritltd-co-uk" {
  vpc_id = "${aws_vpc.k8s-ifritltd-co-uk.id}"

  tags = {
    KubernetesCluster                          = "k8s.ifritltd.co.uk"
    Name                                       = "k8s.ifritltd.co.uk"
    "kubernetes.io/cluster/k8s.ifritltd.co.uk" = "owned"
  }
}

resource "aws_key_pair" "kubernetes-k8s-ifritltd-co-uk-2deb3c8c2bc937e158feb363a0a4c000" {
  key_name   = "kubernetes.k8s.ifritltd.co.uk-2d:eb:3c:8c:2b:c9:37:e1:58:fe:b3:63:a0:a4:c0:00"
  public_key = "${file("${path.module}/data/aws_key_pair_kubernetes.k8s.ifritltd.co.uk-2deb3c8c2bc937e158feb363a0a4c000_public_key")}"
}

resource "aws_launch_configuration" "master-eu-west-2a-masters-k8s-ifritltd-co-uk" {
  name_prefix                 = "master-eu-west-2a.masters.k8s.ifritltd.co.uk-"
  image_id                    = "ami-a59a7fc2"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.kubernetes-k8s-ifritltd-co-uk-2deb3c8c2bc937e158feb363a0a4c000.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-k8s-ifritltd-co-uk.id}"
  security_groups             = ["${aws_security_group.masters-k8s-ifritltd-co-uk.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-eu-west-2a.masters.k8s.ifritltd.co.uk_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 64
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }

  enable_monitoring = false
}

resource "aws_launch_configuration" "nodes-k8s-ifritltd-co-uk" {
  name_prefix                 = "nodes.k8s.ifritltd.co.uk-"
  image_id                    = "ami-a59a7fc2"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.kubernetes-k8s-ifritltd-co-uk-2deb3c8c2bc937e158feb363a0a4c000.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.nodes-k8s-ifritltd-co-uk.id}"
  security_groups             = ["${aws_security_group.nodes-k8s-ifritltd-co-uk.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_nodes.k8s.ifritltd.co.uk_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }

  enable_monitoring = false
}

resource "aws_route" "0-0-0-0--0" {
  route_table_id         = "${aws_route_table.k8s-ifritltd-co-uk.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.k8s-ifritltd-co-uk.id}"
}

resource "aws_route_table" "k8s-ifritltd-co-uk" {
  vpc_id = "${aws_vpc.k8s-ifritltd-co-uk.id}"

  tags = {
    KubernetesCluster                          = "k8s.ifritltd.co.uk"
    Name                                       = "k8s.ifritltd.co.uk"
    "kubernetes.io/cluster/k8s.ifritltd.co.uk" = "owned"
    "kubernetes.io/kops/role"                  = "public"
  }
}

resource "aws_route_table_association" "eu-west-2a-k8s-ifritltd-co-uk" {
  subnet_id      = "${aws_subnet.eu-west-2a-k8s-ifritltd-co-uk.id}"
  route_table_id = "${aws_route_table.k8s-ifritltd-co-uk.id}"
}

resource "aws_security_group" "masters-k8s-ifritltd-co-uk" {
  name        = "masters.k8s.ifritltd.co.uk"
  vpc_id      = "${aws_vpc.k8s-ifritltd-co-uk.id}"
  description = "Security group for masters"

  tags = {
    KubernetesCluster                          = "k8s.ifritltd.co.uk"
    Name                                       = "masters.k8s.ifritltd.co.uk"
    "kubernetes.io/cluster/k8s.ifritltd.co.uk" = "owned"
  }
}

resource "aws_security_group" "nodes-k8s-ifritltd-co-uk" {
  name        = "nodes.k8s.ifritltd.co.uk"
  vpc_id      = "${aws_vpc.k8s-ifritltd-co-uk.id}"
  description = "Security group for nodes"

  tags = {
    KubernetesCluster                          = "k8s.ifritltd.co.uk"
    Name                                       = "nodes.k8s.ifritltd.co.uk"
    "kubernetes.io/cluster/k8s.ifritltd.co.uk" = "owned"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-k8s-ifritltd-co-uk.id}"
  source_security_group_id = "${aws_security_group.masters-k8s-ifritltd-co-uk.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-k8s-ifritltd-co-uk.id}"
  source_security_group_id = "${aws_security_group.masters-k8s-ifritltd-co-uk.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-k8s-ifritltd-co-uk.id}"
  source_security_group_id = "${aws_security_group.nodes-k8s-ifritltd-co-uk.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "https-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-k8s-ifritltd-co-uk.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "master-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.masters-k8s-ifritltd-co-uk.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.nodes-k8s-ifritltd-co-uk.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-to-master-tcp-1-2379" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-k8s-ifritltd-co-uk.id}"
  source_security_group_id = "${aws_security_group.nodes-k8s-ifritltd-co-uk.id}"
  from_port                = 1
  to_port                  = 2379
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-2382-4000" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-k8s-ifritltd-co-uk.id}"
  source_security_group_id = "${aws_security_group.nodes-k8s-ifritltd-co-uk.id}"
  from_port                = 2382
  to_port                  = 4000
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-4003-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-k8s-ifritltd-co-uk.id}"
  source_security_group_id = "${aws_security_group.nodes-k8s-ifritltd-co-uk.id}"
  from_port                = 4003
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-udp-1-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-k8s-ifritltd-co-uk.id}"
  source_security_group_id = "${aws_security_group.nodes-k8s-ifritltd-co-uk.id}"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "udp"
}

resource "aws_security_group_rule" "ssh-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-k8s-ifritltd-co-uk.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-node-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.nodes-k8s-ifritltd-co-uk.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_subnet" "eu-west-2a-k8s-ifritltd-co-uk" {
  vpc_id            = "${aws_vpc.k8s-ifritltd-co-uk.id}"
  cidr_block        = "172.20.32.0/19"
  availability_zone = "eu-west-2a"

  tags = {
    KubernetesCluster                          = "k8s.ifritltd.co.uk"
    Name                                       = "eu-west-2a.k8s.ifritltd.co.uk"
    SubnetType                                 = "Public"
    "kubernetes.io/cluster/k8s.ifritltd.co.uk" = "owned"
    "kubernetes.io/role/elb"                   = "1"
  }
}

resource "aws_vpc" "k8s-ifritltd-co-uk" {
  cidr_block           = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    KubernetesCluster                          = "k8s.ifritltd.co.uk"
    Name                                       = "k8s.ifritltd.co.uk"
    "kubernetes.io/cluster/k8s.ifritltd.co.uk" = "owned"
  }
}

resource "aws_vpc_dhcp_options" "k8s-ifritltd-co-uk" {
  domain_name         = "eu-west-2.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    KubernetesCluster                          = "k8s.ifritltd.co.uk"
    Name                                       = "k8s.ifritltd.co.uk"
    "kubernetes.io/cluster/k8s.ifritltd.co.uk" = "owned"
  }
}

resource "aws_vpc_dhcp_options_association" "k8s-ifritltd-co-uk" {
  vpc_id          = "${aws_vpc.k8s-ifritltd-co-uk.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.k8s-ifritltd-co-uk.id}"
}

terraform = {
  required_version = ">= 0.9.3"
}
