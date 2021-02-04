output vpc_cidrblock {
  value = "${var.vpc_cidrblock}"
}

output vpc_id {
  value = "${aws_vpc.primary.id}"
}

output vgw_id {
  value = "${aws_vpn_gateway.primary.id}"
}
