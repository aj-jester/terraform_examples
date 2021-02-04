variable "vpc_id" {}

variable "domain_names" {
  type = "map"
}

variable "name" {}

variable "region" {}

variable "base_route53_domain" {}

variable "route53_zone_id" {}

variable "available_az" {
  type = "list"
}

variable "num_az" {}

variable "user" {}

variable "environment" {}

variable "vpc_cidrblock" {}

## prepare for private subnet support, but currently set it to false
## COUNT VAR BUG
variable "enable_private_subnet" {
  default = "0"
}

variable "master_type" {
  default = "m3.med"
}

variable "worker_type" {
  default = "m3.large"
}

variable "domain_name_servers" {
  type = "list"

  default = ["AmazonProvidedDNS"]
}

variable "forward_zones" {
  type    = "map"
  default = {}
}

variable "subnet_size" {
  default = "24"
}

variable "subnet_offset" {
  default = "3"
}

variable "subnet_tag_values" {
  type = "map"
}

variable "enable_flow_logs" {
  default = "0"
}

variable "propagating_vgws" {
  type    = "list"
  default = []
}

variable "subnet_assignment" {
  type = "map"
}

variable "subnet_count" {
  type = "map"
}

variable "update_dhcp_options" {
  default = "1"
}

variable "identifier_tags" {
  type    = "map"
  default = {}
}
