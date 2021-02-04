variable "cluster_name" {}

variable "pki_name" {}

variable "common_name" {}

variable "allowed_uses" {
  type = "list"
}

variable "bucket" {}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

output "ca_private_key_pem" {
  value = "${tls_private_key.key.private_key_pem}"
}

output "ca_cert_pem" {
  value = "${tls_self_signed_cert.public_cert.cert_pem}"
}

output "ca_key_algorithm" {
  value = "${tls_private_key.key.algorithm}"
}

variable "version" {
  default = 1
}

resource "aws_s3_bucket_object" "private_key" {
  bucket = "${var.bucket}"
  key    = "${var.cluster_name}/pki/private/${var.pki_name}/${var.version}.key"

  content = "${tls_private_key.key.private_key_pem}"
  etag    = "${md5(tls_private_key.key.private_key_pem)}"
}

resource "tls_self_signed_cert" "public_cert" {
  private_key_pem = "${tls_private_key.key.private_key_pem}"

  subject {
    common_name = "${var.common_name}"
  }

  is_ca_certificate = true
  allowed_uses      = ["${var.allowed_uses}"]

  validity_period_hours = 87600
  key_algorithm         = "${tls_private_key.key.algorithm}"

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket_object" "public_cert" {
  bucket = "${var.bucket}"
  key    = "${var.cluster_name}/pki/issued/${var.pki_name}/${var.version}.crt"

  content = "${tls_self_signed_cert.public_cert.cert_pem}"
  etag    = "${md5(tls_self_signed_cert.public_cert.cert_pem)}"
}
