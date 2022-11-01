locals {
  full_base_domain = join("", [var.env_domain_prefix, var.base_domain])
}

resource "kubernetes_config_map" "configmap-statics" {
  metadata {
    name      = "configmap-statics"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    "NAMESPACE"                = "default"
    "WEBSOCKET_PATH"           = "cable"
    "CACHE_CHANNEL"            = "cache"
    "ENABLE_UNSAFE_METHODS"    = "false"
    "RAILS_SERVE_STATIC_FILES" = "true"
    "RAILS_LOG_TO_STDOUT"      = "true"
    "NODE_ENV"                 = "production"
  }
}

resource "kubernetes_config_map" "configmap-env" {
  metadata {
    name      = "configmap-env"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    RAILS_ENV             = var.env_rails_env
    LOG_LEVEL             = var.env_generic_log_level
    HOSTNAME              = join("", [var.env_domain_prefix, var.base_domain])
    SERVICE_DNS_PREFIX    = join(".", [kubernetes_namespace.this.metadata[0].name, "svc"])
    DATA_SERVICE_NAME     = kubernetes_service.service-services[local.data_provider_service].metadata[0].name
    FRONTEND_SERVICE_PORT = var.services.frontend.port
  }
}

resource "kubernetes_config_map" "configmap-apex" {
  metadata {
    name      = "configmap-apex"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    POSTGRESQL_DATABASE : var.apex_postgresql_database
    RAILS_MAX_THREADS : "15"
    INT_IP_WHITELIST : "10.244.0.0/16"
    AWS_REGION : var.aws_region
    DISABLE_PROMETHEUS : var.enable_prometheus ? "false" : "true"
  }
}

resource "kubernetes_config_map" "configmap-email" {
  metadata {
    name      = "configmap-email"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    MAIL_ADDRESS : var.enable_mailcatcher == true ? "${kubernetes_service.service-mailcatcher[0].metadata[0].name}.${local.app_domain_base}" : var.env_generic_email_mail_address
    MAIL_PORT : var.enable_mailcatcher == true ? kubernetes_service.service-mailcatcher[0].spec[0].port[1].port : var.env_generic_email_mail_port
    EMAIL_SERVICE_DATABASE : var.email_postgresql_database
    INT_IP_WHITELIST : "10.244.0.0/16"
    LOG_LEVEL : coalesce(var.env_generic_email_log_level, var.env_generic_log_level)
  }
}

resource "kubernetes_config_map" "configmap-token" {
  metadata {
    name      = "configmap-token"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    TOKEN_SERVICE_DATABASE : var.token_postgresql_database
    INT_IP_WHITELIST : "10.244.0.0/16"
  }
}

resource "kubernetes_config_map" "configmap-frontend" {
  metadata {
    name      = "configmap-frontend"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    KTOR_ENV             = "production"
    SERVER_REPORTING_KEY = var.env_frontend_server_bugsnag_key
    CLIENT_REPORTING_KEY = var.env_frontend_client_bugsnag_key
    STUDIO_DOMAIN        = local.studio_domain
  }
}
