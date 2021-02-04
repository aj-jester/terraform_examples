output master_instance_profile {
  value = "${aws_iam_instance_profile.masters.id}"
}

output node_instance_profile {
  value = "${aws_iam_instance_profile.nodes.id}"
}

output route53_kubernetes_role_name {
  value = "${aws_iam_role.r53k.name}"
}
