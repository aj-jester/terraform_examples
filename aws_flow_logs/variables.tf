// module: vpc_flow_logs

variable "name" {}

variable "vpc_id" {}

variable "iam_role_permissions_doc" {}

variable "traffic_type" {
  default = "ALL"
}

variable "enable_flow_logs" {
  default = "0"
}

variable "identifier_tags" {
  type    = "map"
  default = {}
}
