// module: vpc_dhcp_options

output id {
  depends_on = ["aws_vpc_dhcp_options_association.main"]
  value      = "${aws_vpc_dhcp_options.main.id}"
}
