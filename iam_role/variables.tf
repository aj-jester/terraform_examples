// module: iam_role

variable "role_name" {}

variable "role_permissions_doc" {}

variable "assumption_permissions" {
  type    = "list"
  default = ["sts:AssumeRole"]
}

variable "service_principals" {
  type    = "list"
  default = []
}

variable "aws_principals" {
  type    = "list"
  default = []
}

variable "federated_principals" {
  type    = "list"
  default = []
}

variable "enable_iam_role" {
  default = "1"
}

variable "enable_service_principals" {
  default = "0"
}

variable "enable_aws_principals" {
  default = "0"
}

variable "enable_federated_principals" {
  default = "0"
}
