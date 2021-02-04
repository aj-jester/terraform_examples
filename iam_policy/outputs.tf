// modul:  iam_policy

output policy_arn {
  value = "${aws_iam_policy.permissions.arn}"
}

output policy_id {
  value = "${aws_iam_policy.permissions.id}"
}
