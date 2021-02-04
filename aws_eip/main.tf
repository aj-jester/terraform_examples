## module: aws_eip

resource "aws_eip" "main" {
  count = "${var.eip_count}"
  vpc   = true
}
