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
    POSTGRESQL_ADDRESS  = var.env_postgresql_address
    POSTGRESQL_PORT     = var.env_postgresql_port
    POSTGRESQL_USERNAME = var.env_postgresql_username
    POSTGRESQL_PASSWORD = var.env_postgresql_password
    POSTGRESQL_URL      = "postgres://${var.env_postgresql_username}:${var.env_postgresql_password}@${var.env_postgresql_address}:${var.env_postgresql_port}"
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
    REDIS_ADDRESS  = var.env_redis_address
    REDIS_PORT     = var.env_redis_port
    REDIS_URL      = "rediss://${var.env_redis_username}:${var.env_redis_password}@${var.env_redis_address}:${var.env_redis_port}"
    REDIS_USERNAME = var.env_redis_username
    REDIS_PASSWORD = var.env_redis_password
    REDIS_SSL      = var.env_redis_ssl
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
    JWT_ENCRYPTION_TOKEN = var.env_jwt_encryption_token

    SERVICE_TOKEN   = var.env_service_token
    LIBRO_APP_ID     = var.env_service_app_id
    LIBRO_APP_SECRET = var.env_service_app_secret

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
    JWT_ENCRYPTION_TOKEN = var.env_jwt_encryption_token

    SERVICE_TOKEN   = var.env_service_token
    LIBRO_APP_ID     = var.env_service_app_id
    LIBRO_APP_SECRET = var.env_service_app_secret

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
    RAILS_OAUTH_TOKEN    = var.env_rails_oauth_token
    SESSION_SECRET       = var.env_secret_key_base
    JWT_ENCRYPTION_TOKEN = var.env_jwt_encryption_token

    EMAIL_SERVICE_URL   = var.env_email_service_url
    TOKEN_SERVICE_URL   = var.env_token_service_url

    LIBRO_CLIENT_ID     = var.env_service_app_id
    LIBRO_CLIENT_SECRET = var.env_service_app_secret
    MAPBOX_USERNAME     = var.env_frontend_mapbox_username
    MAPBOX_KEY          = var.env_frontend_mapbox_key
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
    JWT_ENCRYPTION_TOKEN = var.env_jwt_encryption_token

    SERVICE_TOKEN   = var.env_service_token
    LIBRO_APP_ID     = var.env_service_app_id
    LIBRO_APP_SECRET = var.env_service_app_secret

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
