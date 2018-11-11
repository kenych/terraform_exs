resource "aws_iam_instance_profile" "aws_iam_instance_profile_admin" {
  name_prefix = "credstash_aws_iam_instance_profile-"
  role        = "${aws_iam_role.assume_role_admin.name}"
}

resource "aws_iam_role" "assume_role_admin" {
  name_prefix = "credstash_assume_role_"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "kms_decrypt_role_admin" {
  name_prefix = "kms_decrypt-"
  role        = "${aws_iam_role.assume_role_admin.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:kms:eu-west-1:${data.aws_caller_identity.current.account_id}:key/${data.terraform_remote_state.credstash.kms_key_id}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "dynamodb_credstash_reader_admin" {
  name_prefix = "dynamodb_credstash_reader-"
  role        = "${aws_iam_role.assume_role_admin.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
                  "dynamodb:GetItem",
                  "dynamodb:Query",
                  "dynamodb:Scan"
      ],
      "Resource": "arn:aws:dynamodb:eu-west-1:${data.aws_caller_identity.current.account_id}:table/credential-store",
      "Effect": "Allow"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "kms_encrypt" {
  name_prefix = "kms_encrypt-"
  role        = "${aws_iam_role.assume_role_admin.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:GenerateDataKey"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:kms:eu-west-1:${data.aws_caller_identity.current.account_id}:key/${data.terraform_remote_state.credstash.kms_key_id}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "dynamodb_credstash_writer" {
  name_prefix = "dynamodb_credstash_writer-"
  role        = "${aws_iam_role.assume_role_admin.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
                  "dynamodb:PutItem",
                  "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:eu-west-1:${data.aws_caller_identity.current.account_id}:table/credential-store",
      "Effect": "Allow"
    }
  ]
}
EOF
}
