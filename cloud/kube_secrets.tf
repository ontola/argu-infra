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

# Databases

resource "kubernetes_secret" "wt-secret-db-elasticsearch" {
  metadata {
    name = "wt-secret-db-elasticsearch"
  }

  data = {
    ELASTICSEARCH_URL = var.env_elasticsearch_url
  }
}

resource "kubernetes_secret" "wt-secret-db-postgresql" {
  metadata {
    name = "wt-secret-db-postgresql"
  }

  data = {
    POSTGRESQL_ADDRESS  = local.postgresql_address
    POSTGRESQL_PORT     = local.postgresql_port
    POSTGRESQL_USERNAME = local.postgresql_username
    POSTGRESQL_PASSWORD = local.postgresql_password
    POSTGRESQL_URL      = "postgres://${local.postgresql_username}:${local.postgresql_password}@${local.postgresql_address}:${local.postgresql_port}"
  }
}

resource "kubernetes_secret" "wt-secret-db-mysql" {
  metadata {
    name = "wt-secret-db-mysql"
  }

  data = {
    MYSQL_ADDRESS = var.env_mysql_address
    MYSQL_URL     = "mysql://${var.env_mysql_admin_username}:${var.env_mysql_admin_password}@${var.env_mysql_address}:${var.env_mysql_port}"
  }
}

resource "kubernetes_secret" "wt-secret-db-redis" {
  metadata {
    name = "wt-secret-db-redis"
  }

  data = {
    REDIS_ADDRESS  = local.redis_address
    REDIS_PORT     = local.redis_port
    REDIS_USERNAME = local.redis_username
    REDIS_PASSWORD = local.redis_password
    REDIS_SSL      = var.env_redis_ssl
    REDIS_URL      = "rediss://${local.redis_username}:${local.redis_password}@${local.redis_address}:${local.redis_port}"
  }
}

# Services

resource "kubernetes_secret" "wt-secret-apex" {
  metadata {
    name = "wt-secret-apex"
  }
  type = "Opaque"

  data = {
    SECRET_KEY_BASE      = var.env_secret_key_base
    SECRET_TOKEN         = var.env_secret_token
    JWT_ENCRYPTION_TOKEN = local.jwt_encryption_token

    SERVICE_TOKEN = var.env_service_token

    BUGSNAG_KEY           = var.env_apex_bugsnag_key
    DEVISE_SECRET         = var.env_apex_devise_secret
    DEVISE_PEPPER         = var.env_apex_devise_pepper
    DO_ACCESS_ID          = var.env_service_do_access_id
    DO_ACCESS_SECRET      = var.env_service_do_access_secret
    DO_SPACE_BUCKET       = var.env_service_do_space_bucket
    DO_SPACE_ENDPOINT     = var.env_service_do_space_endpoint
    AWS_ID                = var.env_service_aws_id
    AWS_ACCESS_KEY_ID     = var.env_service_aws_id
    AWS_KEY               = var.env_service_aws_key
    AWS_SECRET_ACCESS_KEY = var.env_service_aws_key
    AWS_BUCKET            = var.env_service_aws_bucket
    FACEBOOK_KEY          = var.env_service_facebook_key
  }
}

resource "kubernetes_secret" "wt-secret-email" {
  metadata {
    name = "wt-secret-email"
  }
  type = "Opaque"

  data = {
    SECRET_KEY_BASE      = var.env_secret_key_base
    SECRET_TOKEN         = var.env_secret_token
    JWT_ENCRYPTION_TOKEN = local.jwt_encryption_token

    SERVICE_TOKEN = var.env_service_token

    BUGSNAG_KEY    = var.env_email_bugsnag_key
    MAILJET_KEY    = var.env_email_mailjet_key
    MAILJET_SECRET = var.env_email_mailjet_secret
  }
}

resource "kubernetes_secret" "wt-secret-frontend" {
  metadata {
    name = "wt-secret-frontend"
  }
  type = "Opaque"

  data = {
    SESSION_SECRET       = var.env_secret_key_base
    JWT_ENCRYPTION_TOKEN = local.jwt_encryption_token

    EMAIL_SERVICE_URL = var.env_email_service_url
    TOKEN_SERVICE_URL = var.env_token_service_url

    MAPBOX_USERNAME = var.env_frontend_mapbox_username
    MAPBOX_KEY      = var.env_frontend_mapbox_key
  }
}

resource "kubernetes_secret" "wt-secret-token" {
  metadata {
    name = "wt-secret-token"
  }
  type = "Opaque"

  data = {
    SECRET_KEY_BASE      = var.env_secret_key_base
    SECRET_TOKEN         = var.env_secret_token
    JWT_ENCRYPTION_TOKEN = local.jwt_encryption_token

    SERVICE_TOKEN = var.env_service_token

    BUGSNAG_KEY = var.env_token_bugsnag_key
  }
}

resource "kubernetes_secret" "wt-secret-matomo" {
  metadata {
    name = "wt-secret-matomo"
  }
  type = "Opaque"

  data = {
    MATOMO_GENERAL_SALT         = var.env_generic_matomo_general_salt
    MATOMO_MAIL_PASSWORD        = var.env_generic_matomo_mail_password
    MATOMO_DATABASE_SSL_CA_PATH = var.env_generic_matomo_database_ca_path
  }
}
