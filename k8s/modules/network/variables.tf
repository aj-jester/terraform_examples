variable "cluster_name" {}

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
  description = "NAT gateways to use for private_subnets. Length must match num_private_subnets"
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

variable "vpc_id" {}

variable "igw" {}

data "aws_vpc" "main" {
  id = "${var.vpc_id}"
}

variable "propagating_vgws" {
  description = "List of virtual gateways that should propagate routes to the route_table"
  type        = "list"
  default     = []
}

variable "identifier_tags" {
  type    = "map"
  default = {}
}
