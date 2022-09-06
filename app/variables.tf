locals {
  data_provider_service = "apex"
}

# Jobs

variable "cache_trigger" {
  type        = string
  default     = "0"
  description = "Increment to trigger the cache clear job"
}

# Infrastructure

variable "cluster_env" {
  type        = string
  default     = "development"
  description = "The environment the cluster is running, development, staging, or production"
}

variable "ip_whitelist" {
  type        = string
  default     = null
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

variable "custom_simple_domains" {
  type        = list(string)
  default     = []
  description = "Domains managed by customers, might contain misconfigurations like missing subdomains or wrong A records"
}

variable "all_domains" {
  type = list(any)
}

variable "analytics_domains" {
  type    = list(any)
  default = []
}

variable "studio_domain" {
  type    = string
  default = null
}

variable "used_issuer" {
  type    = string
  default = null
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "app_namespace" {
  type        = string
  default     = "default"
  description = "The kubernetes namespace to run the app in"
}

variable "application_name" {
  type = string
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

### Env - Generic - Matomo

variable "env_generic_matomo_database_adapter" {
  type    = string
  default = "PDO\\MYSQL"
}

variable "env_generic_matomo_database_ca_path" {
  type    = string
  default = "/var/www/html/config/ca-certificate.crt"
}

variable "env_generic_matomo_database_tables_prefix" {
  type    = string
  default = "matomo_"
}

variable "env_generic_matomo_noreply_address" {
  type = string
}

variable "env_generic_matomo_noreply_name" {
  type = string
}

variable "env_generic_matomo_host" {
  type        = string
  default     = null
  description = "Defaults to analytics_domain.base_domain"
}

variable "env_generic_matomo_defaulthostnameifempty" {
  type        = string
  default     = null
  description = "Defaults to mj.base_domain"
}

variable "env_generic_matomo_mail_encryption" {
  type    = string
  default = "tls"
}

variable "env_generic_matomo_mail_host" {
  type = string
}

variable "env_generic_matomo_mail_password" {
  type      = string
  sensitive = true
}

variable "env_generic_matomo_mail_port" {
  type    = string
  default = "587"
}

variable "env_generic_matomo_mail_transport" {
  type    = string
  default = "smtp"
}

variable "env_generic_matomo_mail_type" {
  type    = string
  default = "PLAIN"
}

variable "env_generic_matomo_mail_username" {
  type = string
}

variable "env_generic_matomo_force_ssl" {
  type    = number
  default = 1
}

variable "env_generic_matomo_database_enable_ssl" {
  type    = number
  default = 1
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

### Env - Databases - MySQL

variable "env_mysql_address" {
  type = string
}

variable "env_mysql_port" {
  type = string
}

variable "env_mysql_database" {
  type = string
}

variable "env_mysql_admin_username" {
  type = string
}

variable "env_mysql_admin_password" {
  type      = string
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
  type = string
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

variable "env_storage_id" {
  type = string
}

variable "env_storage_secret" {
  type      = string
  sensitive = true
}

variable "env_storage_bucket" {
  type = string
}

variable "env_storage_endpoint" {
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

variable "env_matomo_mysql_database" {
  type = string
}

variable "env_generic_matomo_general_salt" {
  type      = string
  sensitive = true
}

# Locals

locals {
  app_domain_base = "${kubernetes_namespace.this.metadata[0].name}.svc.cluster.local"
}
