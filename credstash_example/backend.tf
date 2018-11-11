terraform {
  backend "s3" {
    bucket = "kayan-terra-state"
    key    = "credstash_example.tfstate"
    region = "eu-west-2"
  }
}
