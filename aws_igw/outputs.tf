## module vpc_igw

output igw_id {
  value = "${aws_internet_gateway.igw.id}"
}
