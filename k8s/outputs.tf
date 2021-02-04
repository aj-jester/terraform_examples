output private_key {
  value = "${tls_private_key.key.private_key_pem}"
}

output domain {
  value = "k8s.${var.route53_domain}"
}

output public_route_table_id {
  value = "${module.network.public_route_table_id}"
}

output private_route_table_id {
  value = "${module.network.private_route_table_id}"
}

output master_security_group {
  value = "${module.masters.security_group}"
}

output node_security_group {
  value = "${module.nodes.security_group}"
}
