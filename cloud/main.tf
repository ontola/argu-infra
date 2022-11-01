terraform {
  experiments = [
    module_variable_optional_attrs,
  ]

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.28.0"
    }

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.22.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.6.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.13.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.2"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.1"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "ontola"

    workspaces {
      prefix = "ontola-"
    }
  }
}

data "terraform_remote_state" "shared" {
  backend = "remote"

  config = {
    hostname     = "app.terraform.io"
    organization = "ontola"

    workspaces = {
      name = "shared"
    }
  }
}

resource "random_pet" "tfc_refresh" {
  keepers = {
    refresh : 1
  }
}

module "app" {
  source = "../app"

  app_namespace         = "${var.application_name}-${var.cluster_env}"
  all_domains           = values(local.domains)
  env_elasticsearch_url = local.elastic_url
  used_issuer           = local.used_issuer

  env_storage_id       = var.env_service_do_access_id
  env_storage_secret   = var.env_service_do_access_secret
  env_storage_bucket   = var.env_service_do_space_bucket
  env_storage_endpoint = var.env_service_do_space_endpoint

  cluster_env                               = var.cluster_env
  ip_whitelist                              = var.ip_whitelist == null ? null : join(",", [digitalocean_kubernetes_cluster.k8s-ams3-ontola-apex-1.ipv4_address, var.ip_whitelist])
  base_domain                               = var.base_domain
  env_domain_prefix                         = var.env_domain_prefix
  analytics_subdomain                       = var.analytics_subdomain
  custom_simple_domains                     = var.custom_simple_domains
  aws_region                                = var.aws_region
  application_name                          = var.application_name
  enable_prometheus                         = var.enable_prometheus
  enable_mailcatcher                        = var.enable_mailcatcher
  image_registry                            = var.image_registry
  image_registry_user                       = var.image_registry_user
  image_registry_token                      = var.image_registry_token
  image_tag                                 = var.image_tag
  service_image_tag                         = var.service_image_tag
  env_rails_env                             = var.env_rails_env
  env_generic_log_level                     = var.env_generic_log_level
  env_generic_email_log_level               = var.env_generic_email_log_level
  env_generic_email_mail_address            = var.env_generic_email_mail_address
  env_generic_email_mail_port               = var.env_generic_email_mail_port
  env_postgresql_address                    = local.postgresql_address
  env_postgresql_port                       = local.postgresql_port
  env_postgresql_username                   = local.postgresql_username
  env_postgresql_password                   = local.postgresql_password
  env_redis_address                         = var.env_redis_address
  env_redis_username                        = var.env_redis_username
  env_redis_password                        = var.env_redis_password
  env_redis_port                            = var.env_redis_port
  env_redis_ssl                             = var.env_redis_ssl
  env_service_token                         = var.env_service_token
  env_secret_key_base                       = var.env_secret_key_base
  env_secret_token                          = var.env_secret_token
  env_jwt_encryption_token                  = var.env_jwt_encryption_token
  env_service_aws_id                        = var.env_service_aws_id
  env_service_aws_key                       = var.env_service_aws_key
  env_service_aws_bucket                    = var.env_service_aws_bucket
  env_service_facebook_key                  = var.env_service_facebook_key
  env_apex_bugsnag_key                      = var.env_apex_bugsnag_key
  env_apex_devise_secret                    = var.env_apex_devise_secret
  env_apex_devise_pepper                    = var.env_apex_devise_pepper
  env_email_bugsnag_key                     = var.env_email_bugsnag_key
  env_email_mailjet_key                     = var.env_email_mailjet_key
  env_email_mailjet_secret                  = var.env_email_mailjet_secret
  env_email_service_url                     = var.env_email_service_url
  env_frontend_server_bugsnag_key           = var.env_frontend_server_bugsnag_key
  env_frontend_client_bugsnag_key           = var.env_frontend_client_bugsnag_key
  env_frontend_mapbox_username              = var.env_frontend_mapbox_username
  env_frontend_mapbox_key                   = var.env_frontend_mapbox_key
  env_token_bugsnag_key                     = var.env_token_bugsnag_key
  env_token_service_url                     = var.env_token_service_url
  env_apex_postgresql_database              = var.env_apex_postgresql_database
  env_email_postgresql_database             = var.env_email_postgresql_database
  env_token_postgresql_database             = var.env_token_postgresql_database
}
