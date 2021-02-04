// module: aws_k8s_cluster

data "null_data_source" "subnet_tag_values" {
  inputs = {
    KubernetesCluster = "k8s.${var.user}.${var.base_route53_domain}"
    User              = "${var.user}"
    Environment       = "${var.environment}"
  }
}

data "null_data_source" "s3_tag_values" {
  inputs = {
    Name   = "kubernetes Configs"
    Region = "${var.region}"
    User   = "${var.user}"
  }
}

module "aws_vpc_components" {
  source              = "../aws_vpc_components"
  vpc_id              = "${var.vpc_id}"
  name                = "${var.user}-${var.region}"
  region              = "${var.region}"
  available_az        = "${var.available_az}"
  num_az              = "${var.num_az}"
  base_route53_domain = "${var.base_route53_domain}"
  route53_zone_id     = "${var.route53_zone_id}"
  user                = "${var.user}"
  environment         = "${var.environment}"
  vpc_cidrblock       = "${var.vpc_cidrblock}"
  master_type         = "${var.master_type}"
  worker_type         = "${var.worker_type}"
  forward_zones       = "${var.forward_zones}"
  subnet_offset       = "${var.subnet_offset}"
  domain_names        = "${var.domain_names}"
  subnet_tag_values   = "${data.null_data_source.subnet_tag_values.inputs}"
  identifier_tags     = "${var.identifier_tags}"
  enable_flow_logs    = "${var.enable_flow_logs}"
  propagating_vgws    = ["${var.propagating_vgws}"]
  subnet_assignment   = "${var.subnet_assignment}"
  subnet_count        = "${var.subnet_count}"
  update_dhcp_options = "${1 - var.enable_unbound}"
}

resource "aws_s3_bucket" "s3_k8s" {
  bucket = "sstk-${var.account}-k8s-${var.user}-${var.region}"
  acl    = "private"
  tags   = "${merge(var.identifier_tags, data.null_data_source.s3_tag_values.inputs)}"
}

// number of services subnet =  number_of_az
module "unbound" {
  source           = "../unbound"
  vpc_id           = "${var.vpc_id}"
  available_az     = "${var.available_az}"
  cluster_name     = "${var.environment}-${var.region}"
  environment      = "${var.environment}"
  num_az           = "${var.num_az}"
  services_subnets = "${module.aws_vpc_components.services_subnets}"
  forward_zones    = "${var.forward_zones}"
  enable_unbound   = "${var.enable_unbound}"
  identifier_tags  = "${var.identifier_tags}"
}

module "dhcp_options" {
  source              = "../aws_dhcp_options"
  vpc_id              = "${var.vpc_id}"
  environment         = "${var.environment}"
  domain_name_servers = "${module.unbound.eni_ips}"
  update_dhcp_options = "${var.enable_unbound}"
  identifier_tags     = "${var.identifier_tags}"
}

// Note:  base_route53_domain is  quite populated e.g. us-west-2.sandbox.shuttercloud.org
// num_public_subnets = number_of_az
// num_private/public_subnets is used to define the number of asg  associated with masters,  which is 1 per AZ
module "kubernetes" {
  source              = "../k8s"
  igw_id              = "${module.aws_vpc_components.igw_id}"
  route53_domain      = "${var.user}.${var.base_route53_domain}"
  route53_zone_id     = "${module.aws_vpc_components.route53_zone_id}"
  s3_bucket_arn       = "${aws_s3_bucket.s3_k8s.arn}"
  s3_bucket_id        = "${aws_s3_bucket.s3_k8s.id}"
  user                = "${var.user}"
  vpc_id              = "${var.vpc_id}"
  region              = "${var.region}"
  propagating_vgws    = ["${var.propagating_vgws}"]
  private_subnets     = ["${module.aws_vpc_components.private_subnets}"]
  public_subnets      = ["${module.aws_vpc_components.public_subnets}"]
  num_private_subnets = "${var.num_az * var.enable_private_subnet}"
  num_public_subnets  = "${var.num_az}"
  master_type         = "${var.master_type}"
  worker_type         = "${var.worker_type}"
  worker_max_count    = "${var.worker_max_count}"
  worker_min_count    = "${var.worker_min_count}"
  dhcp_options        = "${module.dhcp_options.id}"
  identifier_tags     = "${var.identifier_tags}"
}
