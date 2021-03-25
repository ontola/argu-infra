locals {
  data_provider_service = "apex"
  cache_provider_service = "cache"
}

# Jobs

variable "cache_trigger" {
  type = string
  default = "0"
  description = "Increment to trigger the cache clear job"
}

# Infrastructure

variable "cluster_env" {
  type = string
  default = "development"
  description = "The environment the cluster is running, development, staging, or production"
}

variable "base_domain" {
  type = string
  description = "The main domain to mount the service on, also used to mount auxiliary services under"
}

variable "env_domain_prefix" {
  type = string
  default = ""
  description = "The subdomain the application is mounted on, including dot (eg 'staging.'). Applied to all domains."
}

variable "automated_domains" {
  type = list(string)
  description = "Domains owned by us, managed by the infrastructure. Don't prefix since env_domain_prefix is honored"
  default = []
}

variable "managed_domains" {
  type = list(string)
  description = "Domains owned by us, managed manually, should have correct DNS settings for all (sub)domains"
  default = []
}

variable "custom_simple_domains" {
  type = list(string)
  description = "Domains managed by customers, might contain misconfigurations like missing subdomains or wrong A records"
  default = []
}

variable "aws_region" {
  type = string
  default = "eu-central-1"
}

variable "do_region" {
  type = string
  default = "ams3"
}

variable "letsencrypt_email" {
  type = string
}

variable "letsencrypt_env_production" {
  type = bool
  default = false
}

variable "app_namespace" {
  type = string
  default = "default"
}

variable "do_token" {
  type = string
  description = "Used to manage the cluster and networking infrastructure"
}

variable "application_name" {
  type = string
  default = "webtools"
}

##  Infrastructure - images
variable "image_registry" {
  type = string
  default = "registry.gitlab.com"
}

variable "image_registry_org" {
  type = string
  default = "ontola"
}

variable "image_registry_user" {
  type = string
  description = "Usually from a deploy token"
}

variable "image_registry_token" {
  type = string
}

variable "image_tag" {
  type = string
  default = "latest"
}

variable "service_image_tag" {
  type = map(string)
  default = {}
}

# Env

variable "env_rails_env" {
  type = string
  default = "staging"
}

## Env - Generic

variable "env_generic_log_level" {
  type = string
  default = "info"
}

### Env - Generic - Email

variable "env_generic_email_log_level" {
  type = string
  default = null
}

variable "env_generic_email_mail_address" {
  type = string
  default = ""
}

variable "env_generic_email_mail_port" {
  type = string
  default = ""
}

## Env - Databases

### Env - Databases - Postgres

variable "env_postgresql_address" {
  type = string
}

variable "env_postgresql_port" {
  type = string
}

variable "env_postgresql_username" {
  type = string
}

variable "env_postgresql_password" {
  type = string
}

### Env - Databases - Rabbitmq

variable "env_rabbitmq_port" {
  type = string
  default = "5672"
}

### Env - Databases - Redis

variable "env_redis_address" {
  type = string
}

variable "env_redis_username" {
  type = string
}

variable "env_redis_password" {
  type = string
}

variable "env_redis_port" {
  type = string
}

### Env - Databases - Elasticsearch

variable "env_elasticsearch_url" {
  type = string
  default = "http://elasticsearch-elasticsearch-coordinating-only.default.svc.cluster.local:9200"
}

### Env - Secrets

### Env - Secrets - General

variable "env_rails_oauth_token" {
  type = string
}

variable "env_service_token" {
  type = string
}

variable "env_secret_key_base" {
  type = string
}

variable "env_secret_token" {
  type = string
}

variable "env_jwt_encryption_token" {
  type = string
}

variable "env_service_app_id" {
  type = string
}

variable "env_service_app_secret" {
  type = string
}

variable "env_service_aws_id" {
  type = string
}

variable "env_service_aws_key" {
  type = string
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
  type = string
}

variable "env_apex_devise_pepper" {
  type = string
}

variable "env_service_apex_nominatim_url" {
  type = string
}

variable "env_service_apex_nominatim_key" {
  type = string
}

### Env - Secrets - Service specific - email

variable "env_email_bugsnag_key" {
  type = string
}

variable "env_email_mailjet_key" {
  type = string
  default = ""
}

variable "env_email_mailjet_secret" {
  type = string
  default = ""
}

### Env - Secrets - Service specific - frontend

variable "env_frontend_bugsnag_key" {
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

## Other env - service specific

variable "env_cache_postgresql_database" {
  type = string
}

variable "env_email_postgresql_database" {
  type = string
}

variable "env_token_postgresql_database" {
  type = string
}

# Versions

variable "ver_chart_cert_manager" { type = string }
variable "ver_chart_elasticsearch" { type = string }
variable "ver_chart_grafana" { type = string }
variable "ver_chart_nginx_ingress" { type = string }
variable "ver_chart_prometheus" { type = string }
variable "ver_chart_rabbitmq" { type = string }

# Locals

locals {
  app_domain_base = "${var.app_namespace}.svc.cluster.local"
}
