variable "workers" {
  description = "Map of kubernetes workers."
  type = list(object({
    service   = string
    image     = string
    component = string
    command   = list(string)
    databases = list(string)
  }))

  default = [
    {
      service   = "apex"
      component = "worker"
      image     = "registry.gitlab.com/ontola/apex"
      command   = ["bundle", "exec", "sidekiq", "--concurrency=2"]
      databases = [
        "elasticsearch",
        "postgresql",
        "redis",
      ]
    },
    {
      service   = "token"
      component = "worker"
      image     = "registry.gitlab.com/ontola/token_service"
      command   = ["bundle", "exec", "sidekiq", "--concurrency=2"]
      databases = [
        "postgresql",
        "redis",
      ]
    },
  ]
}

resource "kubernetes_deployment" "worker-deployments" {
  for_each = { for worker in var.workers : "${worker.service}-${worker.component}" => worker }

  metadata {
    name      = "${each.key}-dep"
    namespace = kubernetes_namespace.this.metadata[0].name
    annotations = {
      "service-name" : each.value.service
      "reloader.stakater.com/auto" : "true"
    }
  }

  spec {
    revision_history_limit = 2
    replicas               = var.cluster_env == "production" ? 0 : 1

    selector {
      match_labels = {
        app : var.application_name
        tier : each.value.service
        component : each.value.component
      }
    }

    template {
      metadata {
        labels = {
          app : var.application_name
          tier : each.value.service
          component : each.value.component
        }
      }
      spec {
        image_pull_secrets {
          name = kubernetes_secret.container-registry-secret.metadata[0].name
        }
        container {
          name    = each.key
          image   = "${each.value.image}:${try(var.service_image_tag[each.value.service], var.image_tag)}"
          command = each.value.command

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
              name = "configmap-${each.value.service}"
            }
          }
          env_from {
            secret_ref {
              name = "secret-${each.value.service}"
            }
          }

          dynamic "env_from" {
            for_each = each.value.databases

            content {
              secret_ref {
                name = "secret-db-${env_from.value}"
              }
            }
          }
        }
      }
    }
  }
}
