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
    name      = "clear-cache-${random_pet.clear-cache-version.id}"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    backoff_limit = 4

    template {
      metadata {
        labels = {
          app : var.application_name
          tier : local.job_cache_clear_service
          component : "job"
        }
      }

      spec {
        image_pull_secrets {
          name = kubernetes_secret.container-registry-secret.metadata[0].name
        }
        container {
          name    = "clear-cache-job"
          image   = "${var.services.apex.image}:${try(var.service_image_tag[local.job_cache_clear_service], var.image_tag)}"
          command = ["bundle", "exec", "rake", "cache:clear"]


          env_from {
            config_map_ref {
              name = "configmap-env"
            }
          }

          env_from {
            config_map_ref {
              name = "configmap-statics"
            }
          }
          env_from {
            config_map_ref {
              name = "configmap-env"
            }
          }
          env_from {
            config_map_ref {
              name = "configmap-${local.job_cache_clear_service}"
            }
          }
          env_from {
            secret_ref {
              name = "secret-${local.job_cache_clear_service}"
            }
          }
          env_from {
            secret_ref {
              name = "secret-db-redis"
            }
          }
          env_from {
            secret_ref {
              name = "secret-db-postgresql"
            }
          }
        }
        restart_policy = "Never"
      }
    }
  }
}


resource "kubernetes_job" "migrate-jobs" {
  for_each = {
    for k, v in var.services : k => v
    if v.migrate
  }

  wait_for_completion = true

  metadata {
    name      = "migrate-${each.key}-${try(var.service_image_tag[each.key], var.image_tag)}"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    backoff_limit = 4

    template {
      metadata {
        labels = {
          app : var.application_name
          tier : local.job_cache_clear_service
          component : "job"
        }
      }

      spec {
        container {
          name    = "migrate-${each.key}-job"
          image   = "${each.value.image}:${try(var.service_image_tag[each.key], var.image_tag)}"
          command = ["bundle", "exec", "rake", "db:migrate"]


          env_from {
            config_map_ref {
              name = "configmap-statics"
            }
          }
          env_from {
            config_map_ref {
              name = "configmap-env"
            }
          }
          env_from {
            config_map_ref {
              name = "configmap-${each.key}"
            }
          }
          env_from {
            secret_ref {
              name = "secret-${each.key}"
            }
          }
          dynamic "env_from" {
            for_each = coalesce(each.value.databases, [])

            content {
              secret_ref {
                name = "secret-db-${env_from.value}"
              }
            }
          }
        }
        restart_policy = "Never"
      }
    }
  }
}
