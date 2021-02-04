## module: vpc_nat_gw

output ngw_ids {
  value = ["${aws_nat_gateway.ngw.*.id}"]
}
