variable "s3_bucket_id" {}

variable "s3_bucket_arn" {}

variable "cluster_name" {}

variable "route53_zone_id" {}

variable "vpc_id" {}

variable "subnets" {
  type = "list"
}

variable "route53_kubernetes_role_name" {}

variable "aws_accountid" {}

// BUG: COUNT VAR
variable num_subnets {}

data "aws_vpc" "main" {
  id = "${var.vpc_id}"
}

data "aws_subnet" "used" {
  count = "${var.num_subnets}"

  id = "${element(var.subnets, count.index)}"
}
