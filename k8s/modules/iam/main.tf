resource "aws_iam_instance_profile" "masters" {
  name = "masters-profile.${var.cluster_name}"

  roles = [
    "${aws_iam_role.masters.name}",
  ]
}

resource "aws_iam_instance_profile" "nodes" {
  name = "nodes-profile.${var.cluster_name}"

  roles = [
    "${aws_iam_role.nodes.name}",
  ]
}

resource "aws_iam_role" "masters" {
  name               = "k8s.masters.${var.cluster_name}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role" "nodes" {
  name               = "k8s.nodes.${var.cluster_name}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role_policy" "masters_common" {
  name   = "masters-common-policy.${var.cluster_name}"
  role   = "${aws_iam_role.masters.name}"
  policy = "${data.aws_iam_policy_document.common.json}"
}

resource "aws_iam_role_policy" "nodes_common" {
  name   = "nodes-common-policy.${var.cluster_name}"
  role   = "${aws_iam_role.nodes.name}"
  policy = "${data.aws_iam_policy_document.common.json}"
}

resource "aws_iam_role_policy" "masters" {
  name   = "masters-policy.${var.cluster_name}"
  role   = "${aws_iam_role.masters.name}"
  policy = "${data.aws_iam_policy_document.masters.json}"
}

resource "aws_iam_role_policy" "nodes" {
  name   = "nodes-policy.${var.cluster_name}"
  role   = "${aws_iam_role.nodes.name}"
  policy = "${data.aws_iam_policy_document.nodes.json}"
}

resource "aws_iam_role" "r53k" {
  name               = "r53k.${var.cluster_name}"
  assume_role_policy = "${data.aws_iam_policy_document.r53k_assume_role.json}"
}

resource "aws_iam_role_policy" "r53k" {
  name   = "r53k-policy.${var.cluster_name}"
  role   = "${aws_iam_role.r53k.name}"
  policy = "${data.aws_iam_policy_document.r53k.json}"
}
