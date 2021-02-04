variable "master_security_group" {}

variable "node_security_group" {}

data "aws_security_group" "master" {
  id = "${var.master_security_group}"
}

data "aws_security_group" "node" {
  id = "${var.node_security_group}"
}

variable "allow_ping_cidr" {
  description = "A CIDR mask from which to allow ICMP pings."
  type        = "list"
  default     = ["10.0.0.0/8"]
}
