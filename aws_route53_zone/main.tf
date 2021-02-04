resource "aws_route53_zone" "main" {
  name              = "${var.zone_fqdn}."
  delegation_set_id = "${var.delegation_set}"

  tags {
    fqdn = "${var.zone_fqdn}"
  }
}
