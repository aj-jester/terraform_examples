// module: aws_route_table

variable "propagating_vgws" {
  type    = "list"
  default = []
}

variable "available_az" {
  type = "list"
}

variable "vpc_id" {}

variable "cluster_name" {}

variable "purpose" {}

variable "route_table_count" {}

variable "identifier_tags" {
  type    = "map"
  default = {}
}
