resource "kubernetes_secret" "secret-db-elasticsearch" {
  metadata {
    name      = "secret-db-elasticsearch"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    ELASTICSEARCH_URL = var.env_elasticsearch_url
  }
}

resource "kubernetes_secret" "secret-db-postgresql" {
  metadata {
    name      = "secret-db-postgresql"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    POSTGRESQL_ADDRESS  = var.env_postgresql_address
    POSTGRESQL_PORT     = var.env_postgresql_port
    POSTGRESQL_USERNAME = var.env_postgresql_username
    POSTGRESQL_PASSWORD = var.env_postgresql_password
    POSTGRESQL_URL      = "postgres://${var.env_postgresql_username}:${var.env_postgresql_password}@${var.env_postgresql_address}:${var.env_postgresql_port}"
  }
}

resource "kubernetes_secret" "secret-db-mysql" {
  metadata {
    name      = "secret-db-mysql"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    MYSQL_ADDRESS = var.env_mysql_address
    MYSQL_URL     = "mysql://${var.env_mysql_admin_username}:${var.env_mysql_admin_password}@${var.env_mysql_address}:${var.env_mysql_port}"
  }
}

resource "kubernetes_secret" "secret-db-redis" {
  metadata {
    name      = "secret-db-redis"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    REDIS_ADDRESS  = var.env_redis_address
    REDIS_PORT     = var.env_redis_port
    REDIS_USERNAME = var.env_redis_username
    REDIS_PASSWORD = var.env_redis_password
    REDIS_SSL      = var.env_redis_ssl
    REDIS_URL      = "${var.env_redis_ssl == true ? "rediss" : "redis"}://${var.env_redis_username}:${var.env_redis_password}@${var.env_redis_address}:${var.env_redis_port}"
  }
}

resource "kubernetes_secret" "secret-apex" {
  metadata {
    name      = "secret-apex"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  type = "Opaque"

  data = {
    SECRET_KEY_BASE      = local.secret_key_base
    SECRET_TOKEN         = local.secret_token
    JWT_ENCRYPTION_TOKEN = local.jwt_encryption_token

    SERVICE_TOKEN = var.env_service_token

    BUGSNAG_KEY           = var.env_apex_bugsnag_key
    DEVISE_SECRET         = var.env_apex_devise_secret
    DEVISE_PEPPER         = var.env_apex_devise_pepper
    DO_ACCESS_ID          = var.env_storage_id
    DO_ACCESS_SECRET      = var.env_storage_secret
    DO_SPACE_BUCKET       = var.env_storage_bucket
    DO_SPACE_ENDPOINT     = var.env_storage_endpoint
    AWS_ID                = var.env_service_aws_id
    AWS_ACCESS_KEY_ID     = var.env_service_aws_id
    AWS_KEY               = var.env_service_aws_key
    AWS_SECRET_ACCESS_KEY = var.env_service_aws_key
    AWS_BUCKET            = var.env_service_aws_bucket
    FACEBOOK_KEY          = var.env_service_facebook_key
  }
}

resource "kubernetes_secret" "secret-email" {
  metadata {
    name      = "secret-email"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  type = "Opaque"

  data = {
    SECRET_KEY_BASE      = local.secret_key_base
    SECRET_TOKEN         = local.secret_token
    JWT_ENCRYPTION_TOKEN = local.jwt_encryption_token

    SERVICE_TOKEN = var.env_service_token

    BUGSNAG_KEY    = var.env_email_bugsnag_key
    MAILJET_KEY    = var.env_email_mailjet_key
    MAILJET_SECRET = var.env_email_mailjet_secret
  }
}

resource "kubernetes_secret" "secret-frontend" {
  metadata {
    name      = "secret-frontend"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  type = "Opaque"

  data = {
    SESSION_SECRET       = local.secret_key_base
    JWT_ENCRYPTION_TOKEN = local.jwt_encryption_token

    EMAIL_SERVICE_URL = var.env_email_service_url
    TOKEN_SERVICE_URL = var.env_token_service_url

    MAPBOX_USERNAME = var.env_frontend_mapbox_username
    MAPBOX_KEY      = var.env_frontend_mapbox_key
  }
}

resource "kubernetes_secret" "secret-token" {
  metadata {
    name      = "secret-token"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  type = "Opaque"

  data = {
    SECRET_KEY_BASE      = local.secret_key_base
    SECRET_TOKEN         = local.secret_token
    JWT_ENCRYPTION_TOKEN = local.jwt_encryption_token

    SERVICE_TOKEN = var.env_service_token

    BUGSNAG_KEY = var.env_token_bugsnag_key
  }
}

resource "kubernetes_secret" "secret-matomo" {
  metadata {
    name      = "secret-matomo"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  type = "Opaque"

  data = {
    MATOMO_GENERAL_SALT         = var.env_generic_matomo_general_salt
    MATOMO_MAIL_PASSWORD        = var.env_generic_matomo_mail_password
    MATOMO_DATABASE_SSL_CA_PATH = var.env_generic_matomo_database_ca_path
  }
}

resource "kubernetes_secret" "container-registry-secret" {
  metadata {
    name      = "container-registry-secret"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = "{\"auths\":{\"${var.image_registry}\":{\"username\":\"${var.image_registry_user}\",\"password\":\"${var.image_registry_token}\",\"auth\":\"${base64encode("${var.image_registry_user}:${var.image_registry_token}")}\"}}}"
  }
}
