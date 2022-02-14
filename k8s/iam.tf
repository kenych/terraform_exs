resource "aws_iam_instance_profile" "aws_iam_instance_profile" {
  name_prefix = "paramstore_aws_iam_instance_profile-"
  role        = "${aws_iam_role.assume_role.name}"
}

resource "aws_iam_role" "assume_role" {
  name_prefix = "paramstore_assume_role_"

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

resource "aws_iam_role_policy" "paramstore" {
  name_prefix = "paramstore-"
  role        = "${aws_iam_role.assume_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:PutParameter",
                "ssm:GetParametersByPath",
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/*"
        }
    ]
}
EOF
}
