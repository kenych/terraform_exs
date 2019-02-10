resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}"
  acl    = "${var.acl}"
  region = "${var.region}"

  versioning = {
    enabled = "${var.versioning}"
  }
}


