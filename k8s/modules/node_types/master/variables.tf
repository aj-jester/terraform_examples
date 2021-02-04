variable "cluster_name" {}

variable "s3_bucket_id" {}

variable "subnets" {
  type = "list"
}

variable "vpc_id" {}

variable "iam_instance_profile" {}

variable "key_name" {}

variable "region" {}

variable "associate_public_ip_address" {
  default     = "1"
  description = "Passed to the launch config for master instances, use '1' or '0'."
}

// BUG: COUNT VAR
variable "num_subnets" {}

variable "instance_type" {
  default = "m3.large"
}

variable "dhcp_options" {}

variable "identifier_tags" {
  type    = "map"
  default = {}
}

data "aws_subnet" "used" {
  count = "${var.num_subnets}"

  id = "${element(var.subnets, count.index)}"
}

// Determine the AMI provided by kops for this region
data "aws_ami" "k8s" {
  most_recent = true

  // Need to look up by ID, for some reason the owner-alias does not work (even though it works in the CLI)
  owners = [
    383156758163,
  ]

  filter {
    name   = "description"
    values = ["Kubernetes 1.4 Base Image - Debian jessie amd64"]
  }
}

data "template_file" "yaml" {
  count = "${var.num_subnets}"

  template = "${file("${path.module}/../templates/_master.yaml")}"

  vars = {
    cluster_name        = "${var.cluster_name}"
    s3_bucket_id        = "${var.s3_bucket_id}"
    instance_group_name = "master-${element(data.aws_subnet.used.*.availability_zone, count.index)}"
  }
}

data "template_file" "user_data" {
  count = "${var.num_subnets}"

  template = "${file("${path.module}/../templates/_user_data.sh")}"

  vars = {
    yaml_data = "${element(data.template_file.yaml.*.rendered, count.index)}"
    region    = "${var.region}"
  }
}
