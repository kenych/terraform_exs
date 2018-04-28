terraform {
  backend "s3" {

    bucket = "kayan-terra-state"
    key = "dev/iam-role/terraform.tfstate"
    region = "eu-west-2"
  }
}