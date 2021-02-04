// All of the IAM policies and role attachments
module "iam" {
  source       = "./modules/iam"
  cluster_name = "${data.template_file.cluster_name.rendered}"

  # route53_domain = e.g. $user.$domain   mency.us-east-1.sandbox.shuttercloud.org
  s3_bucket_arn  = "${var.s3_bucket_arn}"
  route53_domain = "${var.route53_domain}"
}

module "s3" {
  source = "./modules/s3"

  cluster_name                 = "${data.template_file.cluster_name.rendered}"
  s3_bucket_arn                = "${var.s3_bucket_arn}"
  s3_bucket_id                 = "${var.s3_bucket_id}"
  route53_zone_id              = "${var.route53_zone_id}"
  route53_kubernetes_role_name = "${module.iam.route53_kubernetes_role_name}"

  vpc_id  = "${var.vpc_id}"
  subnets = ["${data.aws_subnet.node_subnets.*.id}"]

  aws_accountid = "${data.aws_caller_identity.current.account_id}"

  // BUG: COUNT VAR
  // We can get away with only passing in num_public_subnets because it's only used as a count for
  // iterating over the subnets parameter, which will either be all public or all private.  When private,
  // the number of subnets will still match (since we require that num_private  == num_public or 0).
  // Also, when using private subnets, we don't provision any of the cluster to the pubics, so we can
  // ignore them completely.
  num_subnets = "${var.num_public_subnets}"
}

module "security_group_rules" {
  source = "./modules/security_group_rules"

  master_security_group = "${module.masters.security_group}"
  node_security_group   = "${module.nodes.security_group}"
}

module "etcd" {
  source = "./modules/etcd"

  cluster_name = "${data.template_file.cluster_name.rendered}"

  // BUG: COUNT VAR
  num_subnets     = "${var.num_public_subnets}"
  subnets         = ["${data.aws_subnet.node_subnets.*.id}"]
  identifier_tags = "${var.identifier_tags}"
}

module "network" {
  source = "./modules/network"

  vpc_id          = "${var.vpc_id}"
  cluster_name    = "${data.template_file.cluster_name.rendered}"
  igw             = "${var.igw_id}"
  private_subnets = "${var.private_subnets}"
  public_subnets  = "${var.public_subnets}"

  // BUG: COUNT VAR
  num_public_subnets = "${var.num_public_subnets}"

  // BUG: COUNT VAR
  num_private_subnets = "${var.num_private_subnets}"
  propagating_vgws    = ["${var.propagating_vgws}"]
  nat_gws             = ["${var.nat_gws}"]

  identifier_tags = "${var.identifier_tags}"
}

module "masters" {
  source = "./modules/node_types/master"

  cluster_name  = "${data.template_file.cluster_name.rendered}"
  s3_bucket_id  = "${var.s3_bucket_id}"
  subnets       = ["${data.aws_subnet.node_subnets.*.id}"]
  key_name      = "${aws_key_pair.key.key_name}"
  vpc_id        = "${var.vpc_id}"
  region        = "${var.region}"
  instance_type = "${var.master_type}"
  dhcp_options  = "${var.dhcp_options}"

  // relies on invariant that length(var.private_subnets) is either 0 or equal to var.num_public_subnets
  associate_public_ip_address = "${1 - (length(var.private_subnets) / var.num_public_subnets)}"

  iam_instance_profile = "${module.iam.master_instance_profile}"

  // BUG: COUNT VAR
  num_subnets     = "${var.num_public_subnets}"
  identifier_tags = "${var.identifier_tags}"
}

module "nodes" {
  source = "./modules/node_types/node"

  cluster_name     = "${data.template_file.cluster_name.rendered}"
  s3_bucket_id     = "${var.s3_bucket_id}"
  subnets          = ["${data.aws_subnet.node_subnets.*.id}"]
  key_name         = "${aws_key_pair.key.key_name}"
  vpc_id           = "${var.vpc_id}"
  region           = "${var.region}"
  instance_type    = "${var.worker_type}"
  dhcp_options     = "${var.dhcp_options}"
  worker_max_count = "${var.worker_max_count}"
  worker_min_count = "${var.worker_min_count}"
  num_subnets      = "${var.num_public_subnets == 0?  var.num_private_subnets : var.num_public_subnets}"

  // relies on invariant that length(var.private_subnets) is either 0 or equal to var.num_public_subnets
  associate_public_ip_address = "${1 - (length(var.private_subnets) / var.num_public_subnets)}"

  iam_instance_profile = "${module.iam.node_instance_profile}"
  identifier_tags      = "${var.identifier_tags}"
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "key" {
  key_name   = "kubernetes.k8s.${var.route53_domain}"
  public_key = "${tls_private_key.key.public_key_openssh}"
}
