// module: cloudwatch_log_group

output name {
  value = "${aws_cloudwatch_log_group.main.name}"
}
