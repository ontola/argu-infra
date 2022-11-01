locals {
  postgres_enabled = var.env_postgresql_address == null ? 1 : 0

  db_apex_name  = coalesce(var.env_apex_postgresql_database, one(digitalocean_database_db.apex[*].name))
  db_email_name = coalesce(var.env_email_postgresql_database, one(digitalocean_database_db.email[*].name))
  db_token_name = coalesce(var.env_token_postgresql_database, one(digitalocean_database_db.token[*].name))
}

resource "digitalocean_database_cluster" "postgres" {
  count = local.postgres_enabled

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
  count = local.postgres_enabled

  cluster_id = one(digitalocean_database_cluster.postgres[*].id)
  name       = "postgres"
}

resource "digitalocean_database_firewall" "postgres" {
  count = local.postgres_enabled

  cluster_id = one(digitalocean_database_cluster.postgres[*].id)

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
  count = local.postgres_enabled

  cluster_id = one(digitalocean_database_cluster.postgres[*].id)
  name       = "apex_${var.cluster_env}"
}

resource "digitalocean_database_db" "email" {
  count = local.postgres_enabled

  cluster_id = one(digitalocean_database_cluster.postgres[*].id)
  name       = "email_${var.cluster_env}"
}

resource "digitalocean_database_db" "token" {
  count = local.postgres_enabled

  cluster_id = one(digitalocean_database_cluster.postgres[*].id)
  name       = "token_${var.cluster_env}"
}

resource "random_pet" "pg-user-fallback" {
  keepers = {
    refresh : 1
  }
}

resource "digitalocean_database_user" "postgres-app" {
  count = local.postgres_enabled

  cluster_id = one(digitalocean_database_cluster.postgres[*].id)
  name       = local.postgresql_username
}
