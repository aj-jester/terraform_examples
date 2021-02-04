// module: iam_policy

resource "aws_iam_policy" "permissions" {
  count  = "${var.enable_role_policy}"
  name   = "${var.policy_name}"
  policy = "${var.policy_document}"
}
