variable "do_region" {
  type    = string
  default = "ams3"
}

variable "do_token" {
  type        = string
  description = "Used to manage the cluster and networking infrastructure"
  sensitive   = true
}

variable "env_service_do_access_id" {
  type = string
}

variable "env_service_do_access_secret" {
  type      = string
  sensitive = true
}

variable "env_service_do_space_bucket" {
  type = string
}

variable "env_service_do_space_endpoint" {
  type = string
}

variable "organization" {
  type    = string
  default = "ontola"
}

variable "cluster_version" {
  type        = number
  default     = 0
  description = "Increment to create a new cluster"
}

variable "cluster_env" {
  type        = string
  default     = "development"
  description = "The environment the cluster is running, development, staging, or production"
}

variable "ip_whitelist" {
  type        = string
  default     = "0.0.0.0/0"
  description = "Range of allowed IP addresses"
}

variable "base_domain" {
  type        = string
  description = "The main domain to mount the service on, also used to mount auxiliary services under"
}

variable "env_domain_prefix" {
  type        = string
  default     = ""
  description = "The subdomain the application is mounted on, including dot (eg 'staging.'). Applied to all domains."
}

variable "analytics_subdomain" {
  type    = string
  default = "analytics"
}

variable "managed_domains" {
  type        = list(string)
  description = "Domains owned by us, registered manually, managed via terraform."
  default     = []
}

variable "custom_simple_domains" {
  type        = list(string)
  description = "Domains managed by customers, might contain misconfigurations like missing subdomains or wrong A records"
  default     = []
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "letsencrypt_email" {
  type = string
}

variable "letsencrypt_env_production" {
  type    = bool
  default = false
}

variable "letsencrypt_issuers" {
  type    = bool
  default = true
}

variable "support_namespace_postfix" {
  type        = string
  default     = "support"
  description = "Namespace postfix to install supporting services into"
}

variable "application_name" {
  type    = string
  default = "argu"
}

variable "enable_prometheus" {
  type    = bool
  default = false
}

variable "enable_mailcatcher" {
  type    = bool
  default = false
}

##  Infrastructure - images
variable "image_registry" {
  type    = string
  default = "registry.gitlab.com"
}

variable "image_registry_org" {
  type    = string
  default = "ontola"
}

variable "image_registry_user" {
  type        = string
  description = "Usually from a deploy token"
}

variable "image_registry_token" {
  type      = string
  sensitive = true
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "service_image_tag" {
  type    = map(string)
  default = {}
}

# Env

variable "env_rails_env" {
  type    = string
  default = "staging"
}

## Env - Generic

variable "env_generic_log_level" {
  type    = string
  default = "info"
}

### Env - Generic - Email

variable "env_generic_email_log_level" {
  type    = string
  default = null
}

variable "env_generic_email_mail_address" {
  type    = string
  default = ""
}

variable "env_generic_email_mail_port" {
  type    = string
  default = ""
}

## Env - Databases

### Env - Databases - Postgres

variable "env_postgresql_address" {
  type    = string
  default = null
}

variable "env_postgresql_port" {
  type    = string
  default = null
}

variable "env_postgresql_username" {
  type    = string
  default = null
}

variable "env_postgresql_password" {
  type      = string
  default   = null
  sensitive = true
}

### Env - Databases - Redis

variable "env_redis_address" {
  type    = string
  default = null
}

variable "env_redis_username" {
  type    = string
  default = "default"
}

variable "env_redis_password" {
  type      = string
  default   = null
  sensitive = true
}

variable "env_redis_port" {
  type    = string
  default = null
}

variable "env_redis_ssl" {
  type    = bool
  default = true
}

### Env - Databases - Elasticsearch

variable "env_elasticsearch_url" {
  type    = string
  default = "http://elasticsearch-elasticsearch-coordinating-only.default.svc.cluster.local:9200"
}

### Env - Secrets

### Env - Secrets - General

variable "env_service_token" {
  type      = string
  sensitive = true
}

variable "env_secret_key_base" {
  type      = string
  default   = null
  sensitive = true
}

variable "env_secret_token" {
  type      = string
  default   = null
  sensitive = true
}

variable "env_jwt_encryption_token" {
  type      = string
  default   = null
  sensitive = true
}

variable "env_service_aws_id" {
  type = string
}

variable "env_service_aws_key" {
  type      = string
  sensitive = true
}

variable "env_service_aws_bucket" {
  type = string
}

variable "env_service_facebook_key" {
  type = string
}

### Env - Secrets - Service specific

### Env - Secrets - Service specific - apex

variable "env_apex_bugsnag_key" {
  type = string
}

variable "env_apex_devise_secret" {
  type      = string
  default   = null
  sensitive = true
}

variable "env_apex_devise_pepper" {
  type      = string
  default   = null
  sensitive = true
}

### Env - Secrets - Service specific - email

variable "env_email_bugsnag_key" {
  type = string
}

variable "env_email_mailjet_key" {
  type      = string
  default   = ""
  sensitive = true
}

variable "env_email_mailjet_secret" {
  type    = string
  default = ""
}

variable "env_email_service_url" {
  type = string
}

### Env - Secrets - Service specific - frontend

variable "env_frontend_server_bugsnag_key" {
  type = string
}

variable "env_frontend_client_bugsnag_key" {
  type = string
}

variable "env_frontend_mapbox_username" {
  type = string
}

variable "env_frontend_mapbox_key" {
  type = string
}

### Env - Secrets - Service specific - token

variable "env_token_bugsnag_key" {
  type = string
}

variable "env_token_service_url" {
  type = string
}

## Other env - service specific

variable "env_apex_postgresql_database" {
  type    = string
  default = ""
}

variable "env_email_postgresql_database" {
  type    = string
  default = ""
}

variable "env_token_postgresql_database" {
  type    = string
  default = ""
}

# Versions

variable "ver_chart_cert_manager" {
  description = "https://github.com/jetstack/cert-manager/releases"
  type        = string
}
variable "ver_chart_elasticsearch" { type = string }
variable "ver_chart_grafana" { type = string }
variable "ver_chart_nginx_ingress" {
  description = "https://github.com/kubernetes/ingress-nginx/blob/master/charts/ingress-nginx/CHANGELOG.md"
  type        = string
}
variable "ver_chart_prometheus" {
  description = <<-EOT
  https://github.com/bitnami/charts/tree/master/bitnami/kube-prometheus/
  https://github.com/bitnami/charts/tree/master/bitnami/kube-prometheus/#upgrading
  EOT
  type        = string
}

# Locals

locals {
  app_domain_base = "${module.app.namespace}.svc.cluster.local"
}
