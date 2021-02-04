variable "cluster_name" {}

variable "pki_name" {}

variable "common_name" {}

variable "allowed_uses" {
  type = "list"
}

variable "is_ca_certificate" {
  default = false
}

variable "bucket" {}

variable "ip_addresses" {
  type    = "list"
  default = []
}

variable "dns_names" {
  type    = "list"
  default = []
}

variable "ca_private_key_pem" {}

variable "ca_key_algorithm" {}

variable "ca_cert_pem" {}

output "private_key_pem" {
  value = "${tls_private_key.key.private_key_pem}"
}

output "cert_pem" {
  value = "${tls_locally_signed_cert.public_cert.cert_pem}"
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
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

resource "tls_cert_request" "request" {
  private_key_pem = "${tls_private_key.key.private_key_pem}"

  subject {
    common_name = "${var.common_name}"
  }

  dns_names    = ["${var.dns_names}"]
  ip_addresses = ["${var.ip_addresses}"]

  key_algorithm = "${tls_private_key.key.algorithm}"

  lifecycle = {
    create_before_destroy = true
  }
}

resource "tls_locally_signed_cert" "public_cert" {
  cert_request_pem = "${tls_cert_request.request.cert_request_pem}"

  ca_key_algorithm   = "${var.ca_key_algorithm}"
  ca_private_key_pem = "${var.ca_private_key_pem}"
  ca_cert_pem        = "${var.ca_cert_pem}"

  validity_period_hours = 87600

  allowed_uses = ["${var.allowed_uses}"]
}

resource "aws_s3_bucket_object" "public_cert" {
  bucket = "${var.bucket}"
  key    = "${var.cluster_name}/pki/issued/${var.pki_name}/${var.version}.crt"

  content = "${tls_locally_signed_cert.public_cert.cert_pem}"
  etag    = "${md5(tls_locally_signed_cert.public_cert.cert_pem)}"
}
