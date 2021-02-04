## module: vpc_subnet_public

output subnet_ids {
  value = ["${aws_subnet.main.*.id}"]
}
