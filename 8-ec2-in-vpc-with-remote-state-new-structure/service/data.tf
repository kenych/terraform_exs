data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "kayan-terra-state"
    key = "dev/vpc/terraform.tfstate"
    region = "eu-west-2"
  }
}