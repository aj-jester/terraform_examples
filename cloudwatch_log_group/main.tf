// module: cloudwatch_log_group

resource "aws_cloudwatch_log_group" "main" {
  name              = "${var.cw_log_group_name}"
  retention_in_days = "${var.cw_log_rentention_days}"
}
