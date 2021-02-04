output zone_name {
  value = "${var.environment}.${var.base_dns}"
}

output zone_id {
  value = "${aws_route53_zone.main.zone_id}"
}
