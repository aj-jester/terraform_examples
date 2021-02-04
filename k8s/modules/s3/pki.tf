module "pki_ca" {
  source       = "./modules/pki_ca"
  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"

  pki_name = "ca"

  common_name  = "kubernetes"
  allowed_uses = ["cert_signing"] # TODO: We can't make this have CRL sign, is that needed?
}

module "pki_kubecfg" {
  source       = "./modules/pki"
  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"

  pki_name = "kubecfg"

  common_name  = "kubecfg"
  allowed_uses = ["digital_signature", "client_auth"]

  ca_private_key_pem = "${module.pki_ca.ca_private_key_pem}"
  ca_key_algorithm   = "${module.pki_ca.ca_key_algorithm}"
  ca_cert_pem        = "${module.pki_ca.ca_cert_pem}"
}

module "pki_kubelet" {
  source       = "./modules/pki"
  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"

  pki_name = "kubelet"

  common_name  = "kubelet"
  allowed_uses = ["digital_signature", "client_auth"]

  ca_private_key_pem = "${module.pki_ca.ca_private_key_pem}"
  ca_key_algorithm   = "${module.pki_ca.ca_key_algorithm}"
  ca_cert_pem        = "${module.pki_ca.ca_cert_pem}"
}

# TODO: Also add DNS and IP information
module "pki_master" {
  source       = "./modules/pki"
  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"

  pki_name = "master"

  common_name  = "kubernetes-master"
  allowed_uses = ["digital_signature", "key_encipherment", "server_auth"]

  dns_names = [
    "api.internal.${var.cluster_name}",
    "api.${var.cluster_name}",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster.local",
  ]

  ip_addresses = [
    "100.64.0.1",
  ]

  ca_private_key_pem = "${module.pki_ca.ca_private_key_pem}"
  ca_key_algorithm   = "${module.pki_ca.ca_key_algorithm}"
  ca_cert_pem        = "${module.pki_ca.ca_cert_pem}"
}
