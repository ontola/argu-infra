resource "kubernetes_secret" "wt-secret-db-rabbitmq" {
  metadata {
    name = "wt-secret-db-rabbitmq"
  }

  data = {
    RABBITMQ_ADDRESS = "${helm_release.rabbitmq.name}.${var.app_namespace}.svc.cluster.local"
    RABBITMQ_URL = "ampq://${kubernetes_secret.rabbitmq-credentials.data.username}:${kubernetes_secret.rabbitmq-credentials.data.rabbitmq-password}@${helm_release.rabbitmq.name}.${var.app_namespace}.svc.cluster.local:${var.env_rabbitmq_port}"
  }
}

resource "kubernetes_secret" "wt-secret-db-redis" {
  metadata {
    name = "wt-secret-db-redis"
  }

  data = {
    REDIS_ADDRESS = var.env_redis_address
    REDIS_URL = "rediss://${var.env_redis_username}:${var.env_redis_password}@${var.env_redis_address}:${var.env_redis_port}"
  }
}

resource "kubernetes_secret" "wt-secret-db-postgresql" {
  metadata {
    name = "wt-secret-db-postgresql"
  }

  data = {
    POSTGRESQL_ADDRESS = var.env_postgresql_address
    POSTGRESQL_PORT = var.env_postgresql_port
    POSTGRESQL_USERNAME = var.env_postgresql_username
    POSTGRESQL_PASSWORD = var.env_postgresql_password
    POSTGRESQL_URL = "postgres://${var.env_postgresql_username}:${var.env_postgresql_password}@${var.env_postgresql_address}:${var.env_postgresql_port}"
  }
}

resource "kubernetes_secret" "wt-secret-db-elasticsearch" {
  metadata {
    name = "wt-secret-db-elasticsearch"
  }

  data = {
    ELASTICSEARCH_URL = var.env_elasticsearch_url
  }
}

resource "kubernetes_secret" "wt-secret-apex" {
  metadata {
    name = "wt-secret-apex"
  }
  type = "Opaque"

  data = {
    SECRET_KEY_BASE = var.env_secret_key_base
    SECRET_TOKEN = var.env_secret_token
    JWT_ENCRYPTION_TOKEN = var.env_jwt_encryption_token

    BUGSNAG_KEY = var.env_apex_bugsnag_key
    DEVISE_SECRET = var.env_apex_devise_secret
    DEVISE_PEPPER = var.env_apex_devise_pepper
    AWS_ID = var.env_service_aws_id
    AWS_KEY = var.env_service_aws_key
    FACEBOOK_KEY = var.env_service_facebook_key
  }
}

resource "kubernetes_secret" "wt-secret-cache" {
  metadata {
    name = "wt-secret-cache"
  }
  type = "Opaque"

  data = {
    ARGU_APP_ID = var.env_service_app_id
    ARGU_APP_SECRET = var.env_service_app_secret
    JWT_ENCRYPTION_TOKEN = var.env_jwt_encryption_token
    SERVICE_GUEST_TOKEN = var.env_service_guest_token
    SESSION_SECRET = var.env_secret_key_base
    REDIS_URL = "${kubernetes_secret.wt-secret-db-redis.data.REDIS_URL}/0"
    DATABASE_URL = "${kubernetes_secret.wt-secret-db-postgresql.data.POSTGRESQL_URL}/apex_rs?sslmode=require"
  }
}

resource "kubernetes_secret" "wt-secret-frontend" {
  metadata {
    name = "wt-secret-frontend"
  }
  type = "Opaque"

  data = {
    RAILS_OAUTH_TOKEN = var.env_rails_oauth_token
    SERVICE_GUEST_TOKEN = var.env_service_guest_token
    SESSION_SECRET = var.env_secret_key_base
    JWT_ENCRYPTION_TOKEN = var.env_jwt_encryption_token

    BUGSNAG_KEY = var.env_frontend_bugsnag_key
    LIBRO_CLIENT_ID = var.env_service_app_id
    LIBRO_CLIENT_SECRET = var.env_service_app_secret
    MAPBOX_USERNAME = var.env_frontend_mapbox_username
    MAPBOX_KEY = var.env_frontend_mapbox_key
  }
}
