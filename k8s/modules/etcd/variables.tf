variable "num_subnets" {}

// BUG: COUNT VAR
variable "subnets" {
  type = "list"
}

variable "cluster_name" {}

data "aws_subnet" "used" {
  count = "${var.num_subnets}"

  id = "${element(var.subnets, count.index)}"
}

variable "identifier_tags" {
  type    = "map"
  default = {}
}
