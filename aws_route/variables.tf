// module: aws_route

// gw = igw or vgw
variable "gw_count" {
  default = "0"
}

variable "ngw_count" {
  default = "0"
}

variable "vpc_peering_count" {
  default = "0"
}

variable "instance_count" {
  default = "0"
}

variable "gw_id_list" {
  type    = "list"
  default = []
}

variable "ngw_id_list" {
  type    = "list"
  default = []
}

variable "vpc_peering_id" {
  default = ""
}

variable "instance_id" {
  type    = "list"
  default = []
}

variable "route_table_ids" {
  type = "list"
}

variable "dst_cidr_block" {}
