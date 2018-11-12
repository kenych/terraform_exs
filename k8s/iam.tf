resource "aws_iam_instance_profile" "aws_iam_instance_profile" {
  name_prefix = "credstash_aws_iam_instance_profile-"
  role        = "${aws_iam_role.assume_role.name}"
}

resource "aws_iam_role" "assume_role" {
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

resource "aws_iam_role_policy" "kms" {
  name_prefix = "kms_decrypt-"
  role        = "${aws_iam_role.assume_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:kms:eu-west-1:${data.aws_caller_identity.current.account_id}:key/${data.terraform_remote_state.credstash.kms_key_id}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "dynamodb" {
  name_prefix = "dynamodb_credstash-"
  role        = "${aws_iam_role.assume_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
                  "dynamodb:GetItem",
                  "dynamodb:Query",
                  "dynamodb:Scan",
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
