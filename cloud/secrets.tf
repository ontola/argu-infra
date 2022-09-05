locals {
  postgresql_address  = coalesce(var.env_postgresql_address, one(digitalocean_database_cluster.postgres[*].private_host))
  postgresql_port     = coalesce(var.env_postgresql_port, one(digitalocean_database_cluster.postgres[*].port))
  postgresql_username = coalesce(var.env_postgresql_username, one(digitalocean_database_cluster.postgres[*].user))
  postgresql_password = coalesce(var.env_postgresql_password, one(digitalocean_database_cluster.postgres[*].password))

  redis_address  = coalesce(var.env_redis_address, one(digitalocean_database_cluster.redis[*].private_host))
  redis_port     = coalesce(var.env_redis_port, one(digitalocean_database_cluster.redis[*].port))
  redis_username = coalesce(var.env_redis_username, one(digitalocean_database_cluster.redis[*].user))
  redis_password = coalesce(var.env_redis_password, one(digitalocean_database_cluster.redis[*].password))
}
