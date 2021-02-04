// module: aws_route_table

// gateway supports both igw and vgw

//  there should only be one vgw / igw  for the same route. Maintaining however the same number of routes just for consistency
resource "aws_route" "gw" {
  count                  = "${var.gw_count}"
  route_table_id         = "${element(var.route_table_ids, count.index)}"
  destination_cidr_block = "${var.dst_cidr_block}"
  gateway_id             = "${element(var.gw_id_list, 0)}"
}

//  the count here is for the number of AZ's, because ngw is tied to an AZ, the corresponding number of route table is needed
resource "aws_route" "ngw" {
  count                  = "${var.ngw_count}"
  route_table_id         = "${element(var.route_table_ids, count.index)}"
  destination_cidr_block = "${var.dst_cidr_block}"
  nat_gateway_id         = "${element(var.ngw_id_list, count.index)}"
}

resource "aws_route" "vpc_peering" {
  count                     = "${var.vpc_peering_count}"
  route_table_id            = "${element(var.route_table_ids, count.index)}"
  destination_cidr_block    = "${var.dst_cidr_block}"
  vpc_peering_connection_id = "${var.vpc_peering_id}"
}

//  TODO:  would we need this at all?  Leave it here just for completeness.  The idea is if openswan or alike is used one day
//  it will be per AZ too
resource "aws_route" "instance" {
  count                  = "${var.instance_count}"
  route_table_id         = "${element(var.route_table_ids, count.index)}"
  destination_cidr_block = "${var.dst_cidr_block}"
  instance_id            = "${element(var.instance_id, count.index)}"
}
