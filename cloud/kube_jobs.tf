resource "random_pet" "clear-cache-version" {
  keepers = {
    refresh : var.cache_trigger
  }
}

locals {
  job_cache_clear_service = "apex"
}

resource "kubernetes_job" "clear-cache" {
  wait_for_completion = true

  metadata {
    name = "clear-cache-${random_pet.clear-cache-version.id}"
  }

  spec {
    backoff_limit = 4

    template {
      metadata {
        labels = {
          app: var.application_name
          tier: local.job_cache_clear_service
          component: "job"
        }
      }

      spec {
        container {
          name = "clear-cache-job"
          image = "${var.image_registry}/${var.image_registry_org}/${var.services.apex.image_name}:${try(var.service_image_tag[local.job_cache_clear_service], var.image_tag)}"
          command = ["bundle", "exec", "rake", "cache:clear"]


          env_from {
            config_map_ref {
              name = "wt-configmap-env"
            }
          }

          env_from {
            config_map_ref {
              name = "wt-configmap-statics"
            }
          }
          env_from {
            config_map_ref {
              name = "wt-configmap-env"
            }
          }
          env_from {
            config_map_ref {
              name = "wt-configmap-${local.job_cache_clear_service}"
            }
          }
          env_from {
            secret_ref {
              name = "wt-secret-${local.job_cache_clear_service}"
            }
          }
          env_from {
            secret_ref {
              name = "wt-secret-db-redis"
            }
          }
          env_from {
            secret_ref {
              name = "wt-secret-db-postgresql"
            }
          }
        }
        restart_policy = "Never"
      }
    }
  }
}


resource "kubernetes_job" "migrate-apex" {
  wait_for_completion = true

  metadata {
    name = "migrate-apex-${try(var.service_image_tag[local.job_cache_clear_service], var.image_tag)}"
  }

  spec {
    backoff_limit = 4

    template {
      metadata {
        labels = {
          app: var.application_name
          tier: local.job_cache_clear_service
          component: "job"
        }
      }

      spec {
        container {
          name = "migrate-apex-job"
          image = "${var.image_registry}/${var.image_registry_org}/${var.services.apex.image_name}:${try(var.service_image_tag[local.job_cache_clear_service], var.image_tag)}"
          command = ["bundle", "exec", "rake", "db:migrate"]


          env_from {
            config_map_ref {
              name = "wt-configmap-env"
            }
          }

          env_from {
            config_map_ref {
              name = "wt-configmap-statics"
            }
          }
          env_from {
            config_map_ref {
              name = "wt-configmap-env"
            }
          }
          env_from {
            config_map_ref {
              name = "wt-configmap-${local.job_cache_clear_service}"
            }
          }
          env_from {
            secret_ref {
              name = "wt-secret-${local.job_cache_clear_service}"
            }
          }
          env_from {
            secret_ref {
              name = "wt-secret-db-redis"
            }
          }
          env_from {
            secret_ref {
              name = "wt-secret-db-postgresql"
            }
          }
        }
        restart_policy = "Never"
      }
    }
  }
}
