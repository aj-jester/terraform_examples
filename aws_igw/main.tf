## module: aws_igw

data "null_data_source" "igw_tags" {
  inputs = {
    Environment = "${var.environment}"
    Name        = "${var.environment} - ${data.aws_region.current.name}"
    Region      = "${data.aws_region.current.name}"
  }
}

data "aws_region" "current" {
  current = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${var.vpc_id}"

  tags = "${merge(var.identifier_tags, data.null_data_source.igw_tags.inputs)}"
}
