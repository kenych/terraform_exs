terraform {
  backend "s3" {
    bucket = "kayan-terra-state"
    key    = "simple-ec2-2.tfstate"
    region = "eu-west-2"
  }
}
