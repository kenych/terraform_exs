output "kms_key_id" {
  value = "${aws_kms_key.credstash_kms_key.key_id}"
}
