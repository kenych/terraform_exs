resource "aws_iam_role" "iam_role" {
  name               = "aws_iam_role_m_${var.role_purpose}"
  assume_role_policy = "${var.assume_role_policy}"
}

resource "aws_iam_instance_profile" "iam_instance_profile_m" {
  name = "iam_instance_profile_m_${var.role_purpose}"
  role = "${aws_iam_role.iam_role.name}"
}

resource "aws_iam_role_policy" "iam_role_policy_m" {
  name   = "iam_role_policy_m_${var.role_purpose}"
  role   = "${aws_iam_role.iam_role.id}"
  policy = "${var.aws_iam_role_policy}"
}
