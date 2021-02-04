output "admin_secret" {
  value = "${module.secret_kube.secret}"
}
