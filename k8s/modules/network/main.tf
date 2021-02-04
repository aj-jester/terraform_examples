# Default route for public subnets

data "null_data_source" "rt_tags" {
  inputs = {
    KubernetesCluster = "${var.cluster_name}"
    Name              = "${var.cluster_name}"
  }
}

resource "aws_route" "0-0-0-0--0" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${var.igw}"
}

# Create the route table for public subnets
resource "aws_route_table" "public" {
  vpc_id           = "${data.aws_vpc.main.id}"
  propagating_vgws = ["${var.propagating_vgws}"]

  tags = "${merge (data.null_data_source.rt_tags.inputs, map("Purpose", "Public"), var.identifier_tags )  }"
}

# Association for public subnets
resource "aws_route_table_association" "public-route-table" {
  count = "${var.num_public_subnets}"

  subnet_id      = "${element(var.public_subnets, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

# Create the route table for private subnets
resource "aws_route_table" "private" {
  count            = "${var.num_private_subnets}"
  vpc_id           = "${data.aws_vpc.main.id}"
  propagating_vgws = ["${var.propagating_vgws}"]

  tags = "${merge (data.null_data_source.rt_tags.inputs, map("Purpose", "Private"), var.identifier_tags )  }"
}

# Default route for private subnets
resource "aws_route" "nat-0-0-0-0--0" {
  count                  = "${var.num_private_subnets}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(var.nat_gws, count.index)}"
}

# Association for private subnets
resource "aws_route_table_association" "private-route-table" {
  count = "${var.num_private_subnets}"

  subnet_id      = "${element(var.private_subnets, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
