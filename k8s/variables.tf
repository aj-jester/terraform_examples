// generate the $cluster_name dynamically
// route_domain e.g. mency.us-east-1.sandbox.shuttercloud.org.  No more appending necessary after that!
data "template_file" "cluster_name" {
  template = "k8s.${var.route53_domain}"
}

data "aws_caller_identity" "current" {}

variable "igw_id" {
  description = "An internet gateway, attached to the VPC. Public subnets will be attached to this."
}

variable "region" {
  description = "The region where the cluster runs"
}

variable "route53_domain" {}

#variable base_route53_domain {}

variable "route53_zone_id" {
  description = "DNS zone to add kubernetes records into"
}

variable "s3_bucket_arn" {
  description = "ARN of above S3 bucket used for IAM policies"
}

variable "s3_bucket_id" {
  description = "ID/name for S3 bucket for kubernetes configuration"
}

variable "user" {}

variable "vpc_id" {
  description = "The VPC in which to place this kubernetes cluster"
}

variable "propagating_vgws" {
  description = "List of virtual gateways that should propagate routes to the route_table"
  type        = "list"
  default     = []
}

/*
 * BUG:	COUNT VAR
 * When this is fixed, we can replace all occurences of num_public_subnets with:
 * num_public_subnets = "${length(var.public_subnets)}"
 */
variable "num_public_subnets" {
  description = "The number of public subnets being passed in."
}

/*
 * BUG:	COUNT VAR
 * When this is fixed, we can replace all occurences of num_private_subnets with:
 * num_private_subnets = "${length(var.private_subnets)}"
 */
variable "num_private_subnets" {
  description = "The number of private subnets being passed in. Must either be 0 or match num_public_subnets."
}

variable "public_subnets" {
  description = "Public subnets for the cluster, length must match the value of num_public_subnets"
  type        = "list"
  default     = []
}

variable "private_subnets" {
  description = "Private subnets for the cluster, length must either be zero or match num_private_subnets. Non-zero length indicates a private network topology should be used"
  type        = "list"
  default     = []
}

variable "nat_gws" {
  description = "NAT gateways to use for private_subnets. Length must match num_public_subnets"
  type        = "list"
  default     = []
}

// subnets that should be used for placing nodes
data "aws_subnet" "node_subnets" {
  count = "${var.num_public_subnets}"

  // This depends on the invariant that private_subnets will either be empty or equal to num_public_subnets
  // if private_subnets is not empty, they will be used, otherwise public_subnets will
  id = "${element(concat(var.private_subnets, var.public_subnets), count.index)}"
}

variable "master_type" {
  default = "m3.large"
}

variable "worker_type" {
  default = "m3.large"
}

variable "worker_max_count" {}

variable "worker_min_count" {}

variable "dhcp_options" {}

variable "identifier_tags" {
  type    = "map"
  default = {}
}
