module "secret_admin" {
  source       = "./modules/secret"
  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"

  name = "admin"
}

module "secret_kube" {
  source       = "./modules/secret"
  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"

  name = "kube"
}

module "secret_kube-proxy" {
  source       = "./modules/secret"
  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"

  name = "kube-proxy"
}

module "secret_kubelet" {
  source       = "./modules/secret"
  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"

  name = "kubelet"
}

module "secret_system_controller_manager" {
  source       = "./modules/secret"
  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"

  name = "system:controller_manager"
}

module "secret_system_dns" {
  source       = "./modules/secret"
  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"

  name = "system:dns"
}

module "secret_system_logging" {
  source       = "./modules/secret"
  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"

  name = "system:logging"
}

module "secret_system_monitoring" {
  source       = "./modules/secret"
  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"

  name = "system:monitoring"
}

module "secret_system_scheduler" {
  source       = "./modules/secret"
  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"

  name = "system:scheduler"
}
