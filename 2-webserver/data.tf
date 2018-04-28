data "aws_ip_ranges" "eu-west_regiions_ec2" {
  regions = [ "eu-west-1", "eu-west-2" ]
  services = [ "ec2" ]
}