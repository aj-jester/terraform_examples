## module: aws_subnet_public

data "null_data_source" "is_public" {
  inputs = {
    "nat"     = "1"
    "service" = "0"
    "public"  = "1"
    "private" = "0"
  }
}

data "template_file" "_subnet_name" {
  count = "${var.number_of_az}"

  template = "$${env} - $${subnet_type} - $${az}"

  vars {
    env         = "${lookup(var.tag_values, "Environment", "")}"
    subnet_type = "${var.subnet_type}"
    az          = "${element(var.available_az, count.index)}"
  }
}

resource "aws_subnet" "main" {
  count = "${var.subnet_count * var.enable_subnet}"

  availability_zone = "${element(var.available_az, count.index)}"
  cidr_block        = "${cidrsubnet(var.cidr_block, var.subnet_offset, element( var.subnet_assignment, count.index ))}"
  vpc_id            = "${var.vpc_id}"

  map_public_ip_on_launch = "${data.null_data_source.is_public.inputs[var.subnet_type]}"

  tags = "${merge(map("Name", element(data.template_file._subnet_name.*.rendered, count.index)),var.tag_values, var.identifier_tags) }"
}
