// module: cloudwatch_log_group

variable "cw_log_group_name" {}

/* http://docs.aws.amazon.com/cli/latest/reference/logs/put-retention-policy.html
   The number of days to retain the log events in the specified log group.
   Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653.
*/

variable "cw_log_rentention_days" {
  default = "3653"
}

variable "enable_cw_log_group" {
  default = "0"
}
