resource "aws_ebs_volume" "etcd-events" {
  count = "${var.num_subnets}"

  availability_zone = "${element(data.aws_subnet.used.*.availability_zone, count.index)}"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = "${merge( map ("KubernetesCluster", var.cluster_name),
                  map ("Name", join(".", list(element(data.aws_subnet.used.*.availability_zone, count.index), "etcd-events", var.cluster_name))),
                  map ("k8s.io/etcd/events", join("/", list(element(data.aws_subnet.used.*.availability_zone, count.index),
                                                        join(",", data.aws_subnet.used.*.availability_zone)))),
                  map ("k8s.io/role/master", "1"),
                  var.identifier_tags
    )}"
}

resource "aws_ebs_volume" "etcd-main" {
  count = "${var.num_subnets}"

  availability_zone = "${element(data.aws_subnet.used.*.availability_zone, count.index)}"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = "${merge( map ("KubernetesCluster", var.cluster_name),
                  map ("Name", join(".", list(element(data.aws_subnet.used.*.availability_zone, count.index), "etcd-main", var.cluster_name))),
                  map ("k8s.io/etcd/main", join("/", list(element(data.aws_subnet.used.*.availability_zone, count.index),
                                                        join(",", data.aws_subnet.used.*.availability_zone)))),
                  map ("k8s.io/role/master", "1"),
                  var.identifier_tags
    )}"
}
