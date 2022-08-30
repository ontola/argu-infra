resource "digitalocean_database_cluster" "postgres" {
  name       = "postgresql-${var.organization}-${var.cluster_env}-${var.cluster_version}"
  engine     = "pg"
  version    = "14"
  size       = var.cluster_env != "production" ? "db-s-1vcpu-1gb" : "db-s-1vcpu-2gb"
  region     = var.do_region
  node_count = 1
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

// Required by rails to function properly
resource "digitalocean_database_db" "postgres" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = "postgres"
}

resource "digitalocean_database_firewall" "postgres" {
  cluster_id = digitalocean_database_cluster.postgres.id

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

resource "digitalocean_database_db" "apex" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = "apex_${var.cluster_env}"
}

resource "digitalocean_database_db" "email" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = "email_${var.cluster_env}"
}

resource "digitalocean_database_db" "token" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = "token_${var.cluster_env}"
}
