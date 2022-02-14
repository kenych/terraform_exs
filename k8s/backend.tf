terraform {
  backend "s3" {
    bucket = "kayan-terra-state2"
    key    = "k8s.tfstate"
    region = "eu-west-2"
  }
}
