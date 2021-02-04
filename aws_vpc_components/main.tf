// module: aws_vpc_components

// if subnets are to be parcelled out to e.g. /24 -- leaving the rest of the CIDR empty to be provisioned down to specific subnet types down the road
// need to be able to calculate the subnet_offset when creating the individual subnets
data "template_file" "offset_to_assigned_size" {
  template = "$${val}"

  vars {
    val = "${var.subnet_size - element(split("/",var.vpc_cidrblock),1)}"
  }
}

module "dns" {
  source          = "../dns"
  region          = "${var.region}"
  environment     = "${var.user}"
  base_dns        = "${var.base_route53_domain}"
  parent_zone     = "${var.route53_zone_id}"
  identifier_tags = "${var.identifier_tags}"
}

// if there is unbound, the dhcp_options should be set in aws_k8s_cluster
// if there is no unbound, the following section set dhcp_options to AmazonProvidedDNS
module "dhcp_options" {
  source              = "../aws_dhcp_options"
  vpc_id              = "${var.vpc_id}"
  environment         = "${var.environment}"
  update_dhcp_options = "${var.update_dhcp_options}"
  identifier_tags     = "${var.identifier_tags}"
}

module "internet_gateway" {
  source          = "../aws_igw"
  vpc_id          = "${var.vpc_id}"
  environment     = "${var.environment}"
  identifier_tags = "${var.identifier_tags}"
}

// The following logic assumes the VGW's and NGW's will coexist side by side. where specific routes may be delegated to VGW's,
// leaving NGW to deal with the fall back 0.0.0.0/0

//  NAT subnets will be created from the first /24 of the VPC CIDR block; each subnet will be a /27 as a result
module "nat_subnets" {
  source        = "../aws_subnet"
  vpc_id        = "${var.vpc_id}"
  available_az  = "${var.available_az}"
  user          = "${var.user}"
  environment   = "${var.environment}"
  subnet_offset = "${var.subnet_offset}"

  #  subnet_index_start = "0"

  subnet_count      = "${var.num_az}"
  subnet_assignment = ["0", "1", "2"]
  cidr_block        = "${cidrsubnet(var.vpc_cidrblock, data.template_file.offset_to_assigned_size.rendered, 0)}"
  enable_subnet     = "1"
  subnet_type       = "nat"
  tag_values        = "${var.subnet_tag_values}"
  identifier_tags   = "${var.identifier_tags}"
}

module "nat_route_table" {
  source            = "../aws_route_table"
  vpc_id            = "${var.vpc_id}"
  available_az      = "${var.available_az}"
  cluster_name      = "${var.user} - ${var.environment}"
  route_table_count = "${var.num_az}"
  purpose           = "Nat"
  propagating_vgws  = "${var.propagating_vgws}"
  identifier_tags   = "${var.identifier_tags}"
}

module "nat_route_igw" {
  source          = "../aws_route"
  route_table_ids = "${module.nat_route_table.route_table_ids}"
  dst_cidr_block  = "0.0.0.0/0"
  gw_count        = "3"
  gw_id_list      = ["${module.internet_gateway.igw_id}"]
}

resource "aws_route_table_association" "nat-route-table" {
  count = "${var.num_az}"

  subnet_id      = "${element(module.nat_subnets.subnet_ids, count.index)}"
  route_table_id = "${element(module.nat_route_table.route_table_ids, count.index)}"
}

module "nat_gateways" {
  source         = "../aws_nat_gw"
  vpc_id         = "${var.vpc_id}"
  ngw_count      = "${var.num_az}"
  nat_subnet_ids = "${module.nat_subnets.subnet_ids}"
}

module "services_subnets" {
  source            = "../aws_subnet"
  vpc_id            = "${var.vpc_id}"
  available_az      = "${var.available_az}"
  user              = "${var.user}"
  environment       = "${var.environment}"
  subnet_offset     = "${data.template_file.offset_to_assigned_size.rendered}"
  cidr_block        = "${var.vpc_cidrblock}"
  enable_subnet     = "1"
  subnet_type       = "service"
  subnet_count      = "${lookup(var.subnet_count, "services", 0)}"
  subnet_assignment = "${split(",", lookup(var.subnet_assignment, "services", 0))}"
  tag_values        = "${var.subnet_tag_values}"
  identifier_tags   = "${var.identifier_tags}"
}

module "services_route_table" {
  source            = "../aws_route_table"
  vpc_id            = "${var.vpc_id}"
  available_az      = "${var.available_az}"
  cluster_name      = "${var.user} - ${var.environment}"
  route_table_count = "${var.num_az}"
  purpose           = "Services"
  propagating_vgws  = "${var.propagating_vgws}"
  identifier_tags   = "${var.identifier_tags}"
}

module "services_route_ngw" {
  source          = "../aws_route"
  route_table_ids = "${module.services_route_table.route_table_ids}"
  dst_cidr_block  = "0.0.0.0/0"
  ngw_count       = "${var.num_az}"
  ngw_id_list     = "${module.nat_gateways.ngw_ids}"
}

resource "aws_route_table_association" "services-route-table" {
  count = "${var.num_az}"

  subnet_id      = "${element(module.services_subnets.subnet_ids, count.index)}"
  route_table_id = "${element(module.services_route_table.route_table_ids, count.index)}"
}

// enable_private_subnet refers to where k8s nodes are located

module "public_subnets" {
  source            = "../aws_subnet"
  vpc_id            = "${var.vpc_id}"
  available_az      = "${var.available_az}"
  user              = "${var.user}"
  environment       = "${var.environment}"
  subnet_offset     = "${data.template_file.offset_to_assigned_size.rendered}"
  subnet_count      = "${lookup(var.subnet_count, "public", 0)}"
  subnet_assignment = "${split(",", lookup(var.subnet_assignment, "public", 0))}"
  cidr_block        = "${var.vpc_cidrblock}"
  enable_subnet     = "1"
  subnet_type       = "public"
  tag_values        = "${var.subnet_tag_values}"
  identifier_tags   = "${var.identifier_tags}"
}

module "private_subnets" {
  source            = "../aws_subnet"
  vpc_id            = "${var.vpc_id}"
  available_az      = "${var.available_az}"
  user              = "${var.user}"
  environment       = "${var.environment}"
  subnet_offset     = "${data.template_file.offset_to_assigned_size.rendered}"
  subnet_count      = "${lookup(var.subnet_count, "private", 0)}"
  subnet_assignment = "${split(",", lookup(var.subnet_assignment, "private", 0))}"
  cidr_block        = "${var.vpc_cidrblock}"
  enable_subnet     = "${var.enable_private_subnet}"
  subnet_type       = "private"
  tag_values        = "${var.subnet_tag_values}"
  identifier_tags   = "${var.identifier_tags}"
}

module "flow_logs" {
  source                   = "../aws_flow_logs"
  enable_flow_logs         = "${var.enable_flow_logs}"
  name                     = "${var.user}-${var.environment}"
  vpc_id                   = "${var.vpc_id}"
  iam_role_permissions_doc = "${file("${path.module}/policy_documents/flow_log_permissions.json")}"
  identifier_tags          = "${var.identifier_tags}"
}
