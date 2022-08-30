resource "digitalocean_database_cluster" "redis" {
  name            = "redis-${var.organization}-${var.cluster_env}-${var.cluster_version}"
  engine          = "redis"
  version         = "6"
  size            = var.cluster_env != "production" ? "db-s-1vcpu-1gb" : "db-s-1vcpu-2gb"
  region          = var.do_region
  node_count      = 1
  eviction_policy = "noeviction"
  lifecycle {
    prevent_destroy = false
  }

  tags = [
    local.cluster_name,
    "${var.organization}-${var.cluster_env}",
    var.cluster_env,
    local.cluster_name,
  ]
}

resource "digitalocean_database_firewall" "redis" {
  cluster_id = digitalocean_database_cluster.redis.id

  depends_on = [
    digitalocean_kubernetes_cluster.k8s-ams3-ontola-apex-1
  ]

  rule {
    type  = "tag"
    value = local.cluster_name
  }

  rule {
    type  = "tag"
    value = "k8s-dexpods-${var.cluster_env}"
  }
}
