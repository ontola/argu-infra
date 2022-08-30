resource "digitalocean_project" "this" {
  name        = "${var.organization}-${var.cluster_env}"
  description = "Terraform managed project. Org: ${var.organization}, app: ${var.application_name}, region: ${var.do_region}, version: ${var.cluster_version}"
  purpose     = var.application_name
  environment = var.cluster_env

  resources = concat(
    values(digitalocean_domain.this)[*].urn,
    [
      digitalocean_kubernetes_cluster.k8s-ams3-ontola-apex-1.urn,
      data.digitalocean_loadbalancer.this.urn,
      digitalocean_database_cluster.postgres.urn,
      digitalocean_database_cluster.redis.urn,
    ]
  )
}
