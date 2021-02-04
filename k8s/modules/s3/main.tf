data "template_file" "etcd_members" {
  count    = "${var.num_subnets}"
  template = "    - name: $${availability_zone}\n      zone: $${availability_zone}"

  vars {
    availability_zone = "${element(data.aws_subnet.used.*.availability_zone, count.index)}"
  }
}

data "template_file" "subnets" {
  count    = "${var.num_subnets}"
  template = "    - cidr: $${cidr_block}\n      name: $${availability_zone}\n      id: $${id}"

  vars {
    availability_zone = "${element(data.aws_subnet.used.*.availability_zone, count.index)}"
    cidr_block        = "${element(data.aws_subnet.used.*.cidr_block, count.index)}"
    id                = "${element(data.aws_subnet.used.*.id, count.index)}"
  }
}

data "template_file" "config" {
  template = "${file("${path.module}/templates/_config")}"

  vars = {
    cluster_name = "${var.cluster_name}"
    s3_bucket_id = "${var.s3_bucket_id}"
    vpc_cidr     = "${data.aws_vpc.main.cidr_block}"
    vpc_id       = "${data.aws_vpc.main.id}"
    etc_members  = "${join("\n", data.template_file.etcd_members.*.rendered)}"
    subnets      = "${join("\n", data.template_file.subnets.*.rendered)}"
  }
}

data "template_file" "cluster_spec" {
  template = "${file("${path.module}/templates/_cluster.spec")}"

  vars = {
    cluster_name = "${var.cluster_name}"

    s3_bucket_id = "${var.s3_bucket_id}"
    vpc_cidr     = "${data.aws_vpc.main.cidr_block}"
    vpc_id       = "${data.aws_vpc.main.id}"
    etc_members  = "${join("\n", data.template_file.etcd_members.*.rendered)}"
    subnets      = "${join("\n", data.template_file.subnets.*.rendered)}"

    dns_zone = "${var.route53_zone_id}"

    #pod_cidr = "172.16.0.0/12"
    pod_cidr = "10.123.45.0/29"
  }
}

resource "aws_s3_bucket_object" "config" {
  bucket = "${var.s3_bucket_id}"
  key    = "${var.cluster_name}/config"

  content = "${data.template_file.config.rendered}"
  etag    = "${md5(data.template_file.config.rendered)}"
}

resource "aws_s3_bucket_object" "cluster_spec" {
  bucket = "${var.s3_bucket_id}"
  key    = "${var.cluster_name}/cluster.spec"

  content = "${data.template_file.cluster_spec.rendered}"
  etag    = "${md5(data.template_file.cluster_spec.rendered)}"
}

resource "aws_s3_bucket_object" "instance_group_node" {
  bucket = "${var.s3_bucket_id}"
  key    = "${var.cluster_name}/instancegroup/nodes-${var.cluster_name}"

  content = "${data.template_file.instance_group_nodes.rendered}"
  etag    = "${md5(data.template_file.instance_group_nodes.rendered)}"
}

data "template_file" "node_zones" {
  count    = "${var.num_subnets}"
  template = "  - $${availability_zone}"

  vars {
    availability_zone = "${element(data.aws_subnet.used.*.availability_zone, count.index)}"
  }
}

data "template_file" "instance_group_nodes" {
  template = "${file("${path.module}/templates/instancegroup/_nodes")}"

  vars = {
    node_zones = "${join("\n", data.template_file.node_zones.*.rendered)}"
  }
}

data "template_file" "master" {
  count = "${var.num_subnets}"

  template = "${file("${path.module}/templates/instancegroup/_master")}"

  vars = {
    availability_zone = "${element(data.aws_subnet.used.*.availability_zone, count.index)}"
  }
}

resource "aws_s3_bucket_object" "instance_group_master" {
  count = "${var.num_subnets}"

  bucket = "${var.s3_bucket_id}"
  key    = "${var.cluster_name}/instancegroup/master-${element(data.aws_subnet.used.*.availability_zone, count.index)}"

  content = "${element(data.template_file.master.*.rendered, count.index)}"
  etag    = "${md5(element(data.template_file.master.*.rendered, count.index))}"
}
