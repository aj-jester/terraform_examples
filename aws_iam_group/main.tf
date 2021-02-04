# module: iam_group

resource "aws_iam_group" "main" {
  name = "${var.name}"
}

resource "aws_iam_group_policy_attachment" "main" {
  group      = "${aws_iam_group.main.name}"
  policy_arn = "${var.policy_arn}"
}

resource "aws_iam_group_membership" "main" {
  name  = "${aws_iam_group.main.name}"
  group = "${aws_iam_group.main.name}"
  users = ["${var.users}"]
}
