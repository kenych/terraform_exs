resource "aws_kms_key" "credstash_kms_key" {
  description = "KMS key for credstash"
}

resource "aws_kms_alias" "alias" {
  name          = "alias/credstash"
  target_key_id = "${aws_kms_key.credstash_kms_key.key_id}"
}

resource "aws_dynamodb_table" "credential_store" {
  name           = "credential-store"
  read_capacity  = "10"
  write_capacity = "10"
  hash_key       = "name"
  range_key      = "version"

  attribute {
    name = "name"
    type = "S"
  }

  attribute {
    name = "version"
    type = "S"
  }
}

provider "aws" {
  region = "eu-west-1"
}

