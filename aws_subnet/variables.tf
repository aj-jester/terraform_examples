// module: aws_subnet

// default:   enable subnet creation.  Useful for determining if private subnet
//      should be created based on whether private subnet should be created in the first place
variable "enable_subnet" {
  default = "1"
}

variable "cidr_block" {}

variable "subnet_offset" {}

variable "vpc_id" {}

variable "available_az" {
  type = "list"
}

variable "user" {}

variable "environment" {}

variable "number_of_az" {
  default = "3"
}

variable "subnet_type" {}

variable "tag_values" {
  type = "map"
}

variable "subnet_count" {}

variable "subnet_assignment" {
  type = "list"
}

variable "identifier_tags" {
  type    = "map"
  default = {}
}
