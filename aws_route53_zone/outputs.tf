output "id" {
  value = "${aws_route53_zone.main.zone_id}"
}

output "name" {
  value = "${var.zone_fqdn}"
}

output "name_servers" {
  value = "${aws_route53_zone.main.name_servers}"
}
