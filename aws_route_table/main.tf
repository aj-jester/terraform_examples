// module: aws_route_table

resource "aws_route_table" "main" {
  count            = "${var.route_table_count}"
  vpc_id           = "${var.vpc_id}"
  propagating_vgws = ["${var.propagating_vgws}"]
  tags             = "${merge(map( "Name", "${var.cluster_name} - ${var.purpose} - ${element(var.available_az, count.index)}"), var.identifier_tags)}"
}
