data "null_data_source" "dns_tags" {
  inputs = {
    Environment = "${var.environment}"
    Name        = "${var.environment} - ${var.region}"
    Region      = "${var.region}"
  }
}

resource "aws_route53_zone" "main" {
  name = "${var.environment}.${var.base_dns}"

  tags = "${ merge (var.identifier_tags, data.null_data_source.dns_tags.inputs) }"
}

resource "aws_route53_record" "main" {
  name    = "${var.environment}.${var.base_dns}"
  zone_id = "${var.parent_zone}"

  ttl  = "30"
  type = "NS"

  records = [
    "${aws_route53_zone.main.name_servers.0}",
    "${aws_route53_zone.main.name_servers.1}",
    "${aws_route53_zone.main.name_servers.2}",
    "${aws_route53_zone.main.name_servers.3}",
  ]
}
