data "aws_iam_policy_document" "common" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:BatchGetImage",
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "route53:*",
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "${var.s3_bucket_arn}",
      "${var.s3_bucket_arn}/*",
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      "${var.s3_bucket_arn}",
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "masters" {
  statement {
    actions = [
      "ec2:*",
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "elasticloadbalancing:*",
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "ssm:DescribeAssociation",
      "ssm:GetDocument",
      "ssm:ListAssociations",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceInformation",
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply",
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "nodes" {
  statement {
    actions = [
      "ec2:Describe*",
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "ssm:DescribeAssociation",
      "ssm:GetDocument",
      "ssm:ListAssociations",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceInformation",
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply",
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
    sid    = ""
  }
}

data "aws_iam_policy_document" "r53k" {
  statement {
    actions = [
      "route53:ListResourceRecordSets",
      "route53:ListHostedZones",
      "route53:DeleteHostedZones",
      "route53:ListHostedZonesByName",
      "route53:ChangeResourceRecordSets",
      "elasticloadbalancing:DescribeLoadBalancers",
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "r53k_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }

  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "${aws_iam_role.nodes.arn}",
        "${aws_iam_role.masters.arn}",
      ]
    }

    effect = "Allow"
  }
}
