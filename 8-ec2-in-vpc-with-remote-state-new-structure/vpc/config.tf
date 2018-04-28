terraform {
  backend "s3" {
    bucket = "kayan-terra-state"
    key    = "dev/vpc/terraform.tfstate"
    region = "eu-west-2"
  }
}
