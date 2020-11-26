locals {
  data_provider_service = "apex"
  cache_provider_service = "cache"
}

# Infrastructure

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

variable "system_namespace" {
  type = string
  default = "c66-system"
}

variable "app_namespace" {
  type = string
  default = "default"
}

variable "cluster_host" {
  type = string
}

variable "do_token" {
  type = string
}

variable "cluster_credentials" {
  type = object({
    username = string
    password = string
  })
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

variable "env_service_guest_token" {
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
