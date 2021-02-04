resource "aws_security_group_rule" "all-master-to-master" {
  type              = "ingress"
  security_group_id = "${data.aws_security_group.master.id}"
  self              = true
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type                     = "ingress"
  security_group_id        = "${data.aws_security_group.node.id}"
  source_security_group_id = "${data.aws_security_group.master.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-master" {
  type                     = "ingress"
  security_group_id        = "${data.aws_security_group.master.id}"
  source_security_group_id = "${data.aws_security_group.node.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type              = "ingress"
  security_group_id = "${data.aws_security_group.node.id}"
  self              = true
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

resource "aws_security_group_rule" "https-external-to-master" {
  type              = "ingress"
  security_group_id = "${data.aws_security_group.master.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "master-egress" {
  type              = "egress"
  security_group_id = "${data.aws_security_group.master.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type              = "egress"
  security_group_id = "${data.aws_security_group.node.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-master" {
  type              = "ingress"
  security_group_id = "${data.aws_security_group.master.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-node" {
  type              = "ingress"
  security_group_id = "${data.aws_security_group.node.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ping-to-master" {
  type              = "ingress"
  security_group_id = "${data.aws_security_group.master.id}"
  protocol          = "icmp"
  from_port         = "8"
  to_port           = "0"
  cidr_blocks       = "${compact(var.allow_ping_cidr)}"
}

resource "aws_security_group_rule" "ping-to-node" {
  type              = "ingress"
  security_group_id = "${data.aws_security_group.node.id}"
  protocol          = "icmp"
  from_port         = "8"
  to_port           = "0"
  cidr_blocks       = "${compact(var.allow_ping_cidr)}"
}
