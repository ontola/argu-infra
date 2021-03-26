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
