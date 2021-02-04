data "aws_region" "current" {
  current = true
}

resource "aws_customer_gateway" "main" {
  bgp_asn    = "${var.bgp_asn}"
  ip_address = "${var.ip_address}"
  type       = "${var.type}"

  tags {
    Destination = "${var.datacenter}"
    Name        = "${data.aws_region.current.name} <-> ${var.datacenter}"
    Region      = "${data.aws_region.current.name}"
  }
}
