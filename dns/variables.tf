variable "base_dns" {}

variable "environment" {}

variable "parent_zone" {}

variable "region" {}

variable "identifier_tags" {
  type    = "map"
  default = {}
}
