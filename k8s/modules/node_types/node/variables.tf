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
  description = "Passed to the launch config for node instances, use '1' or '0'."
}

variable "instance_type" {
  default = "m3.medium"
}

variable "dhcp_options" {}

variable "worker_max_count" {}

variable "worker_min_count" {}

variable "num_subnets" {}

variable "identifier_tags" {
  type    = "map"
  default = {}
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
  template = "${file("${path.module}/../templates/_node.yaml")}"

  vars = {
    cluster_name = "${var.cluster_name}"
    s3_bucket_id = "${var.s3_bucket_id}"
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/../templates/_user_data.sh")}"

  vars = {
    yaml_data = "${data.template_file.yaml.rendered}"
    region    = "${var.region}"
  }
}
