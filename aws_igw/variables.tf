## module: vpc_igw

variable "vpc_id" {}

variable "environment" {}

variable "identifier_tags" {
  type    = "map"
  default = {}
}
