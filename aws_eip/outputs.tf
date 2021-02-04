## module: vpc_eip

output eip_alloc_id {
  value = ["${aws_eip.main.*.id}"]
}
