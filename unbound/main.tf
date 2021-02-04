# module: unbound

data "null_data_source" "unbound_tags" {
  inputs = {
    key   = "Name"
    value = "unbound.${var.cluster_name}"
  }
}

data "aws_subnet" "services_subnets" {
  count = "${var.num_az}"

  id = "${element(var.services_subnets, count.index)}"
}

data "aws_vpc" "selected" {
  id = "${data.aws_subnet.services_subnets.0.vpc_id}"
}

data "aws_ami" "centos" {
  most_recent = true
  owners      = [679593333241]

  filter {
    name   = "description"
    values = ["CentOS Linux 7 x86_64 HVM EBS 1602"]
  }
}

data "template_file" "forward_zones" {
  count    = "${length(var.forward_zones)}"
  template = "\nforward-zone:\n  name: $${zone_name}\n$${forward_addrs}"

  vars = {
    zone_name     = "${element(keys(var.forward_zones), count.index)}"
    forward_addrs = "${join("\n", formatlist("  forward-addr: %s",
      split(",", lookup(var.forward_zones, element(keys(var.forward_zones), count.index)))))}"
  }
}

data "template_file" "vpc_dns" {
  template = "$${val}"

  vars = {
    val = "${cidrhost(data.aws_vpc.selected.cidr_block, 2)}"
  }
}

data "template_file" "user_data" {
  count = "${var.num_az * var.enable_unbound}"

  template = "${file("${path.module}/templates/_user_data.sh")}"

  vars = {
    eni_id        = "${element(aws_network_interface.dns.*.id, count.index)}"
    forward_zones = "${join("\n", data.template_file.forward_zones.*.rendered)}"
    vpc_dns       = "${cidrhost(data.aws_vpc.selected.cidr_block, 2)}"
  }
}

data "template_file" "_subnet_name" {
  count = "${var.num_az * var.enable_unbound}"

  template = "$${env} - unbound - $${az}"

  vars {
    env = "${var.environment}"
    az  = "${element(var.available_az, count.index)}"
  }
}

resource "tls_private_key" "key" {
  count     = "${var.enable_unbound}"
  algorithm = "RSA"
}

resource "aws_key_pair" "key" {
  count      = "${var.enable_unbound}"
  key_name   = "unbound-${var.cluster_name}"
  public_key = "${tls_private_key.key.public_key_openssh}"
}

resource "aws_security_group" "dns" {
  name        = "unbound.dns.${var.cluster_name}"
  count       = "${var.enable_unbound}"
  description = "Allow Unbound DNS traffic"
  vpc_id      = "${data.aws_vpc.selected.id}"

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_vpc.selected.cidr_block}"]
    self        = true
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["${data.aws_vpc.selected.cidr_block}"]
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface" "dns" {
  count = "${var.num_az * var.enable_unbound}"

  description = "Unbound DNS ${var.cluster_name}"

  subnet_id       = "${element(var.services_subnets, count.index)}"
  security_groups = ["${aws_security_group.dns.id}"]

  tags = "${merge(var.identifier_tags, data.null_data_source.unbound_tags.inputs)}"
}

resource "aws_security_group" "ssh" {
  count       = "${var.enable_unbound}"
  name        = "unbound.ssh.${var.cluster_name}"
  description = "Allow Unbound SSH"
  vpc_id      = "${data.aws_vpc.selected.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  tags = "${merge(var.identifier_tags, data.null_data_source.unbound_tags.inputs)}"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    sid     = ""
    actions = ["sts:AssumeRole"]

    principals = [
      {
        type        = "Service"
        identifiers = ["ec2.amazonaws.com"]
      },
    ]
  }
}

resource "aws_iam_role" "instance_role" {
  count              = "${var.enable_unbound}"
  name               = "unbound.${var.cluster_name}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

data "aws_iam_policy_document" "eni" {
  statement {
    effect = "Allow"
    sid    = ""

    actions = [
      "ec2:AttachNetworkInterface",
      "ec2:DetachNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "assume_role" {
  count  = "${var.enable_unbound}"
  name   = "unbound.${var.cluster_name}"
  role   = "${aws_iam_role.instance_role.id}"
  policy = "${data.aws_iam_policy_document.eni.json}"
}

resource "aws_iam_instance_profile" "dns" {
  count = "${var.enable_unbound}"
  name  = "unbound.${var.cluster_name}"
  roles = ["${aws_iam_role.instance_role.name}"]
}

resource "aws_launch_configuration" "dns" {
  count = "${var.num_az * var.enable_unbound}"

  name_prefix = "unbound.${var.cluster_name}."

  image_id      = "${data.aws_ami.centos.image_id}"
  instance_type = "${var.instance_type}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }

  associate_public_ip_address = false

  security_groups = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.dns.id}", # needed to pass ELB health checks.
  ]

  iam_instance_profile = "${aws_iam_instance_profile.dns.name}"
  user_data            = "${element(data.template_file.user_data.*.rendered, count.index)}"
  key_name             = "${aws_key_pair.key.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

# No traffic passes through this ELB.
resource "aws_elb" "health_elb" {
  count           = "${var.enable_unbound}"
  name            = "unbound-hlth-${var.cluster_name}"
  subnets         = ["${data.aws_subnet.services_subnets.*.id}"]
  security_groups = ["${aws_security_group.dns.id}"]
  internal        = true

  listener {
    instance_port     = 53
    instance_protocol = "TCP"
    lb_port           = 80
    lb_protocol       = "TCP"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 3
    target              = "TCP:53"
    interval            = 30
  }

  tags = "${merge(var.identifier_tags, data.null_data_source.unbound_tags.inputs)}"
}

resource "aws_autoscaling_group" "dns" {
  count = "${var.num_az * var.enable_unbound}"

  name = "unbound-${var.cluster_name}-${element(data.aws_subnet.services_subnets.*.availability_zone, count.index)}-${element(aws_launch_configuration.dns.*.name, count.index)}"

  launch_configuration = "${element(aws_launch_configuration.dns.*.id, count.index)}"

  availability_zones  = ["${element(data.aws_subnet.services_subnets.*.availability_zone, count.index)}"]
  vpc_zone_identifier = ["${element(data.aws_subnet.services_subnets.*.id, count.index)}"]

  load_balancers    = ["${aws_elb.health_elb.name}"]
  health_check_type = "ELB"
  min_elb_capacity  = 1

  min_size = 1
  max_size = 1

  tag = {
    key                 = "Name"
    value               = "unbound.${var.cluster_name}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Team"
    value               = "${lookup(var.identifier_tags, "Team")}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Owner"
    value               = "${lookup(var.identifier_tags, "Owner")}"
    propagate_at_launch = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}
