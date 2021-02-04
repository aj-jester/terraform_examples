resource "aws_launch_configuration" "main" {
  count = "${var.num_subnets}"

  name_prefix                 = "master-${element(data.aws_subnet.used.*.availability_zone, count.index)}.masters-${var.cluster_name}"
  image_id                    = "${data.aws_ami.k8s.image_id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  iam_instance_profile        = "${var.iam_instance_profile}"
  security_groups             = ["${aws_security_group.main.id}"]
  associate_public_ip_address = "${var.associate_public_ip_address}"
  user_data                   = "${element(data.template_file.user_data.*.rendered, count.index)}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  ephemeral_block_device = {
    device_name  = "/dev/sdc"
    virtual_name = "ephemeral0"
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "main" {
  count = "${var.num_subnets}"

  name                 = "master-${element(data.aws_subnet.used.*.availability_zone, count.index)}.masters.${var.cluster_name}-${element(aws_launch_configuration.main.*.id, count.index)}"
  launch_configuration = "${element(aws_launch_configuration.main.*.id, count.index)}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${element(var.subnets, count.index)}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "${var.cluster_name}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-${element(data.aws_subnet.used.*.availability_zone, count.index)}.masters.${var.cluster_name}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
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

resource "aws_security_group" "main" {
  name        = "masters.${var.cluster_name}"
  vpc_id      = "${var.vpc_id}"
  description = "Security group for masters"

  tags = {
    KubernetesCluster = "${var.cluster_name}"
    Name              = "masters.${var.cluster_name}"
    dhcp_options      = "${var.dhcp_options}"
  }
}
