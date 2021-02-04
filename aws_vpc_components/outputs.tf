output igw_id {
  value = "${module.internet_gateway.igw_id}"
}

output services_subnets {
  value = ["${module.services_subnets.subnet_ids}"]
}

output private_subnets {
  value = ["${module.private_subnets.subnet_ids}"]
}

output public_subnets {
  value = ["${module.public_subnets.subnet_ids}"]
}

output nat_gws {
  value = ["${module.nat_gateways.ngw_ids}"]
}

output route53_zone_id {
  value = "${module.dns.zone_id}"
}
