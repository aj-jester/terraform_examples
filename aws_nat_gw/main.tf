## module: aws_nat_gw

module "aws_eip" {
  source    = "../aws_eip"
  eip_count = "${var.ngw_count}"

  #  eip_count = "3"
}

## Bug: COUNT DYNAMIC

## it is a static look up right now to switch between 3 (when private subnet is used, therefore nat gateways are required),
##  0 (when private subnets are not used,  therefore no nat required)
## This is likely related to https://github.com/hashicorp/terraform/issues/1497, more importantly https://github.com/hashicorp/terraform/issues/3888

resource "aws_nat_gateway" "ngw" {
  count = "${var.ngw_count}"

  subnet_id     = "${element(var.nat_subnet_ids, count.index)}"
  allocation_id = "${element(module.aws_eip.eip_alloc_id, count.index)}"
}
