variable "vpc_id" {}

variable "domain_names" {
  type = "map"
}

variable "region" {}

variable "available_az" {
  type = "list"
}

variable "num_az" {}

variable "base_route53_domain" {}

variable "route53_zone_id" {}

variable "user" {}

variable "environment" {}

variable "vpc_cidrblock" {}

variable "propagating_vgws" {
  type    = "list"
  default = []
}

## prepare for private subnet support, but currently set it to false
## COUNT VAR BUG
variable "enable_private_subnet" {
  default = "0"
}

variable "master_type" {
  default = "m4.large"
}

variable "worker_type" {
  default = "m4.large"
}

variable "forward_zones" {
  type = "map"
}

variable "num_subnets" {
  default = "3"
}

variable "subnet_offset" {
  default = "3"
}

variable "enable_flow_logs" {
  default = "0"
}

variable "enable_unbound" {}

variable "subnet_assignment" {
  type = "map"
}

variable "subnet_count" {
  type = "map"
}

variable "account" {
  default = "sandbox"
}

variable "worker_max_count" {
  default = "3"
}

variable "worker_min_count" {
  default = "3"
}

variable "identifier_tags" {
  type    = "map"
  default = {}
}
