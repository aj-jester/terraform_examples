// module: vpc_dhcp_options

variable "domain_names" {
  type = "map"

  default = {
    us-east-1 = "ec2.internal"
  }
}

variable "domain_name_servers" {
  type = "list"

  default = ["AmazonProvidedDNS"]
}

variable "environment" {}

variable "vpc_id" {}

variable "update_dhcp_options" {
  default = "1"
}

variable "identifier_tags" {
  type    = "map"
  default = {}
}
