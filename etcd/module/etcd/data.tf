data "aws_ami" "ubuntu_1604" {
  most_recent = true
  name_regex  = "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-[0-9]*"
}

data "aws_route53_zone" "zone" {
  name = "k8s.ifritltd.co.uk."
}
