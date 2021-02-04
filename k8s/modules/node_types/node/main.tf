resource "aws_launch_configuration" "main" {
  name_prefix                 = "nodes.${var.cluster_name}-"
  image_id                    = "${data.aws_ami.k8s.image_id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  iam_instance_profile        = "${var.iam_instance_profile}"
  security_groups             = ["${aws_security_group.main.id}"]
  associate_public_ip_address = "${var.associate_public_ip_address}"
  user_data                   = "${data.template_file.user_data.rendered}"

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
  name                 = "nodes.${var.cluster_name}.${aws_launch_configuration.main.id}"
  launch_configuration = "${aws_launch_configuration.main.id}"
  max_size             = "${var.worker_max_count}"
  min_size             = "${var.worker_min_count - var.num_subnets < 0 ?   var.num_subnets: var.worker_min_count}"
  vpc_zone_identifier  = ["${var.subnets}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "${var.cluster_name}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.${var.cluster_name}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/node"
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
  name        = "nodes.${var.cluster_name}"
  vpc_id      = "${var.vpc_id}"
  description = "Security group for nodes"

  tags = {
    KubernetesCluster = "${var.cluster_name}"
    Name              = "nodes.${var.cluster_name}"
    dhcp_options      = "${var.dhcp_options}"
  }
}
