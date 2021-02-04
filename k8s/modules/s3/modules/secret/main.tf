variable "bucket" {}

variable "cluster_name" {}

variable "name" {}

resource "random_id" "data" {
  byte_length = 32
}

data "template_file" "secret" {
  template = "{\"Data\":\"$${data}\"}"

  vars {
    data = "${base64encode(random_id.data.b64)}"
  }
}

resource "aws_s3_bucket_object" "secret" {
  bucket = "${var.bucket}"
  key    = "${var.cluster_name}/secrets/${var.name}"

  content = "${data.template_file.secret.rendered}"
  etag    = "${md5(data.template_file.secret.rendered)}"
}

output "secret" {
  value = "${random_id.data.b64}"
}
