## module: aws_nat_gw

variable "ngw_count" {}

variable "nat_subnet_ids" {
  type = "list"
}

variable "vpc_id" {}
