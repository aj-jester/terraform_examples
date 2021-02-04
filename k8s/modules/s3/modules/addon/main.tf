variable "bucket" {}

variable "cluster_name" {}

variable "path" {}

variable "vars" {
  type    = "map"
  default = {}
}

variable "name" {}

data "template_file" "template" {
  template = "${file(join("/", list("${var.path}", "${var.name}")))}"

  vars = "${var.vars}"
}

resource "aws_s3_bucket_object" "content" {
  bucket = "${var.bucket}"
  key    = "${join("/", list("${var.cluster_name}", "addons", "${var.name}"))}"

  content = "${data.template_file.template.rendered}"
  etag    = "${md5(data.template_file.template.rendered)}"
}
