terraform {
  backend "s3" {
    bucket = "kayan-terra-state"
    key    = "dev/service/terraform.tfstate"
    region = "eu-west-2"
  }
}
