module "addons_core" {
  source = "./modules/addon"

  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"
  path         = "${path.module}/templates/addons"

  name = "core/v1.4.0.yaml"
}

module "addons_dashboard" {
  source = "./modules/addon"

  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"
  path         = "${path.module}/templates/addons"

  name = "kubernetes-dashboard/v1.4.0.yaml"
}

module "addons_dns_controller" {
  source = "./modules/addon"

  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"
  path         = "${path.module}/templates/addons"

  name = "dns-controller/v1.4.1.yaml"

  vars = {
    route53_role    = "${var.route53_kubernetes_role_name}"
    route53_zone_id = "${var.route53_zone_id}"
  }
}

module "addons_kubedns" {
  source = "./modules/addon"

  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"
  path         = "${path.module}/templates/addons"

  name = "kube-dns/v1.4.0.yaml"
}

module "addons_bootstrap_channel" {
  source = "./modules/addon"

  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"
  path         = "${path.module}/templates/addons"

  name = "bootstrap-channel.yaml"
}

module "addons_kube2iam" {
  source = "./modules/addon"

  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"
  path         = "${path.module}/templates/addons"

  name = "kube2iam/latest.yaml"

  vars = {
    aws_accountid = "${var.aws_accountid}"
  }
}

module "addons_route53_kubernetes" {
  source = "./modules/addon"

  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"
  path         = "${path.module}/templates/addons"

  name = "route53-kubernetes/v1.3.0.yaml"

  vars = {
    route53_role = "${var.route53_kubernetes_role_name}"
  }
}

module "addons_fluentd_elasticsearch" {
  source = "./modules/addon"

  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"
  path         = "${path.module}/templates/addons"

  name = "fluentd-elasticsearch/v1.20.yaml"
}

module "addons_heapster_influx" {
  source = "./modules/addon"

  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"
  path         = "${path.module}/templates/addons"

  name = "heapster-influx/1.3.0-beta.0.yaml"
}

module "addons_configmapcontroller" {
  source = "./modules/addon"

  bucket       = "${var.s3_bucket_id}"
  cluster_name = "${var.cluster_name}"
  path         = "${path.module}/templates/addons"

  name = "configmapcontroller/v2.3.5.yaml"
}
