resource "kubernetes_config_map" "wt-configmap-statics" {
  metadata {
    name = "wt-configmap-statics"
  }

  data = {
    "NAMESPACE" = "default"
    "WEBSOCKET_PATH" = "cable"
    "CACHE_CHANNEL" = "cache"
    "ENABLE_UNSAFE_METHODS" = "false"
    "RAILS_SERVE_STATIC_FILES" = "true"
    "RAILS_LOG_TO_STDOUT" = "true"
    "NODE_ENV" = "production"
  }
}

resource "kubernetes_config_map" "wt-configmap-env" {
  metadata {
    name = "wt-configmap-env"
  }

  data = {
    RAILS_ENV = var.env_rails_env
    LOG_LEVEL = var.env_generic_log_level
    HOSTNAME = join("", [var.env_domain_prefix, var.base_domain])
    ARGU_API_URL = "http://${kubernetes_service.service-services[local.data_provider_service].metadata[0].name}.${local.app_domain_base}:${kubernetes_service.service-services[local.data_provider_service].spec[0].port[0].target_port}"
  }
}

resource "kubernetes_config_map" "wt-configmap-apex" {
  metadata {
    name = "wt-configmap-apex"
  }

  data = {
    POSTGRESQL_DATABASE: var.env_apex_postgresql_database
    RAILS_MAX_THREADS: "15"
    INT_IP_WHITELIST: "10.244.0.0/16"
    AWS_REGION: var.aws_region
  }
}

resource "kubernetes_config_map" "wt-configmap-email" {
  metadata {
    name = "wt-configmap-email"
  }

  data = {
    MAIL_ADDRESS: var.cluster_env != "production" ? "${kubernetes_service.service-mailcatcher[0].metadata[0].name}.${local.app_domain_base}" : var.env_generic_email_mail_address
    MAIL_PORT: var.cluster_env != "production" ? kubernetes_service.service-mailcatcher[0].spec[0].port[1].port : var.env_generic_email_mail_port
    EMAIL_SERVICE_DATABASE: var.env_email_postgresql_database
    INT_IP_WHITELIST: "10.244.0.0/16"
    LOG_LEVEL: coalesce(var.env_generic_email_log_level, var.env_generic_log_level)
  }
}

resource "kubernetes_config_map" "wt-configmap-token" {
  metadata {
    name = "wt-configmap-token"
  }

  data = {
    TOKEN_SERVICE_DATABASE: var.env_token_postgresql_database
    INT_IP_WHITELIST: "10.244.0.0/16"
  }
}

resource "kubernetes_config_map" "wt-configmap-cache" {
  metadata {
    name = "wt-configmap-cache"
  }

  data = {
    RUST_LOG = "trace"
    PROXY_TIMEOUT = "30"
    SESSION_COOKIE_NAME = "koa:sess"
    SESSION_COOKIE_SIGNATURE_NAME = "koa:sess.sig"
  }
}

resource "kubernetes_config_map" "wt-configmap-frontend" {
  metadata {
    name = "wt-configmap-frontend"
  }
}

resource "kubernetes_config_map" "wt-configmap-matomo" {
  metadata {
    name = "wt-configmap-matomo"
  }

  data = {
    MYSQL_DATABASE = var.env_matomo_mysql_database
    MATOMO_DATABASE_TABLES_PREFIX = var.env_generic_matomo_database_tables_prefix
    MATOMO_DATABASE_ADAPTER = var.env_generic_matomo_database_adapter
    MATOMO_DATABASE_ENABLE_SSL = var.env_generic_matomo_database_enable_ssl
    MATOMO_GENERAL_NOREPLY_EMAIL_ADDRESS = var.env_generic_matomo_noreply_address
    MATOMO_GENERAL_NOREPLY_EMAIL_NAME = var.env_generic_matomo_noreply_name
    MATOMO_HOST = coalesce(var.env_generic_matomo_host, "${var.analytics_subdomain}.${var.base_domain}")
    MATOMO_MAIL_DEFAULTHOSTNAMEIFEMPTY = coalesce(var.env_generic_matomo_defaulthostnameifempty, "mj.${var.base_domain}")
    MATOMO_MAIL_ENCRYPTION = var.env_generic_matomo_mail_encryption
    MATOMO_MAIL_HOST = var.env_generic_matomo_mail_host
    MATOMO_MAIL_PORT = var.env_generic_matomo_mail_port
    MATOMO_MAIL_TRANSPORT = var.env_generic_matomo_mail_transport
    MATOMO_MAIL_TYPE = var.env_generic_matomo_mail_type
    MATOMO_MAIL_USERNAME = var.env_generic_matomo_mail_username
    MATOMO_GENERAL_LOGIN_ALLOWLIST_APPLY_TO_REPORTING_API_REQUESTS = 0
    MATOMO_GENERAL_FORCE_SSL = var.env_generic_matomo_force_ssl
  }
}
