// module: iam_role

/* NOTE:
    the Terraform docs do not show this elegant way to get the trust policies set.  Great example on
     https://github.com/hashicorp/terraform/issues/5541
*/

// I:  Trust policies

data "aws_iam_policy_document" "assume_policy_data_svc" {
  statement {
    actions = "${var.assumption_permissions}"

    principals {
      type        = "Service"
      identifiers = ["${var.service_principals}"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "assume_policy_data_aws" {
  statement {
    actions = "${var.assumption_permissions}"

    principals {
      type        = "AWS"
      identifiers = ["${var.aws_principals}"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "assume_policy_data_federated" {
  statement {
    actions = "${var.assumption_permissions}"

    principals {
      type        = "Federated"
      identifiers = ["${var.federated_principals}"]
    }

    effect = "Allow"
  }
}

// II : role

resource "aws_iam_role" "svc" {
  count              = "${var.enable_iam_role * var.enable_service_principals}"
  name               = "${var.role_name}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_policy_data_svc.json}"
}

resource "aws_iam_role" "aws" {
  count              = "${var.enable_iam_role * var.enable_aws_principals}"
  name               = "${var.role_name}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_policy_data_aws.json}"
}

resource "aws_iam_role" "federated" {
  count              = "${var.enable_iam_role * var.enable_federated_principals}"
  name               = "${var.role_name}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_policy_data_federated.json}"
}

// III:  policy

module role_policy {
  source             = "../iam_policy"
  policy_name        = "${var.role_name}-permissions"
  policy_document    = "${var.role_permissions_doc}"
  enable_role_policy = "${var.enable_iam_role}"
}

resource "aws_iam_role_policy_attachment" "svc_assume_attachment" {
  count      = "${var.enable_iam_role * var.enable_service_principals}"
  role       = "${aws_iam_role.svc.name}"
  policy_arn = "${module.role_policy.policy_arn}"
}

resource "aws_iam_role_policy_attachment" "aws_assume_attachment" {
  count      = "${var.enable_iam_role * var.enable_aws_principals}"
  role       = "${aws_iam_role.aws.name}"
  policy_arn = "${module.role_policy.policy_arn}"
}

resource "aws_iam_role_policy_attachment" "federated_assume_attachment" {
  count      = "${var.enable_iam_role * var.enable_federated_principals}"
  role       = "${aws_iam_role.federated.name}"
  policy_arn = "${module.role_policy.policy_arn}"
}
