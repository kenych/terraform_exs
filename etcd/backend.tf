terraform {
  backend "s3" {
    bucket = "kayan-terra-state"
    key    = "etcd.tfstate"
    region = "eu-west-2"
  }
}
