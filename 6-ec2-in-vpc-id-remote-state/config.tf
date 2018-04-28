terraform {
  backend "s3" {
    bucket = "kayan-terra-state"
    key    = "dev/ec2/terraform.tfstate"
    region = "eu-west-2"
  }
}
