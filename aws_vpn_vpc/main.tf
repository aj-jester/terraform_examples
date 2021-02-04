resource "aws_vpc" "primary" {
  cidr_block           = "${var.vpc_cidrblock}"
  enable_dns_hostnames = true

  tags {
    Environment = "${var.user}"
    Name        = "${var.user} - ${var.region}"
    Region      = "${var.region}"
  }
}

resource "aws_vpn_gateway" "primary" {
  count  = "${var.num_cgws}"
  vpc_id = "${aws_vpc.primary.id}"

  tags {
    Destination = "cgw: ${element(var.customer_gateways, count.index)}"
    Name        = "${var.region} <-> cgw: ${element(var.customer_gateways, count.index)}"
    Region      = "${var.region}"
  }
}

resource "aws_vpn_connection" "primary" {
  count = "${var.num_cgws}"

  customer_gateway_id = "${element(var.customer_gateways, count.index)}"
  static_routes_only  = false
  type                = "ipsec.1"
  vpn_gateway_id      = "${aws_vpn_gateway.primary.id}"

  tags {
    Destination = "cgw: ${element(var.customer_gateways, count.index)}"
    Name        = "${var.region} <-> cgw: ${element(var.customer_gateways, count.index)}"
    Region      = "${var.region}"
  }

  lifecycle = {
    prevent_destroy = true
  }
}
