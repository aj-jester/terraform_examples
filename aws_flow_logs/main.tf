// module: aws_flow_logs

module "cw_log_group" {
  source              = "../cloudwatch_log_group"
  cw_log_group_name   = "${var.name}-cloudwatch-log"
  enable_cw_log_group = "${var.enable_flow_logs}"
}

module "iam_role" {
  source               = "../iam_role"
  role_name            = "${var.name}-flow-log"
  role_permissions_doc = "${var.iam_role_permissions_doc}"
  service_principals   = ["vpc-flow-logs.amazonaws.com"]

  enable_service_principals = "1"
  enable_iam_role           = "${var.enable_flow_logs}"
}

resource "aws_flow_log" "main" {
  count          = "${var.enable_flow_logs}"
  log_group_name = "${module.cw_log_group.name}"
  iam_role_arn   = "${module.iam_role.role_svc_arn}"
  vpc_id         = "${var.vpc_id}"
  traffic_type   = "${var.traffic_type}"
}
