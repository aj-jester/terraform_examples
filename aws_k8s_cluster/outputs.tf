// module: aws_k8s_cluster

output "master_security_group" {
  value = "${module.kubernetes.master_security_group}"
}

output "node_security_group" {
  value = "${module.kubernetes.node_security_group}"
}

output "public_subnet_ids" {
  value = "${module.aws_vpc_components.public_subnets}"
}

output "unbound_private_key_pem" {
  value = "${module.unbound.private_key_pem}"
}

output "dhcp_options_id" {
  value = "${module.dhcp_options.id}"
}
