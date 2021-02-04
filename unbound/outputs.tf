# module: unbound

/*
Flatten nested lists
https://github.com/hashicorp/terraform/issues/8696
*/
output "eni_ips" {
  depends_on = ["aws_autoscaling_group.dns"]

  value = ["${split(",",
    replace(
      replace(
        replace(
          format("%s", aws_network_interface.dns.*.private_ips), "/[^\\s\\d\\.]/", ""
          ), "/(\\d)\\s+/", "$1,"
        ), "/\\s+/", ""
      )
    )}"]
}

output "security_group" {
  value = "${aws_security_group.dns.id}"
}

output "private_key_pem" {
  value = "${tls_private_key.key.private_key_pem}"
}
