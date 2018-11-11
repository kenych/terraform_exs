terraform {
  backend "s3" {
    bucket = "kayan-terra-state"
    key    = "credstash.tfstate"
    region = "eu-west-2"
  }
}
