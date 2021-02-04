# module: unbound

variable "vpc_id" {}

variable "available_az" {
  type = "list"
}

variable "cluster_name" {}

variable "num_az" {}

variable "environment" {}

variable "forward_zones" {
  type    = "map"
  default = {}
}

variable "instance_type" {
  default = "m4.xlarge"
}

variable "enable_unbound" {}

variable "services_subnets" {
  type = "list"
}

variable "identifier_tags" {
  type    = "map"
  default = {}
}
