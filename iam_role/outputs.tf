// module: iam_role

output role_svc_arn {
  value = "${aws_iam_role.svc.arn}"
}

output role_aws_arn {
  value = "${aws_iam_role.aws.arn}"
}

output role_federated_arn {
  value = "${aws_iam_role.federated.arn}"
}

output policy_arn {
  value = "${module.role_policy.policy_arn}"
}
