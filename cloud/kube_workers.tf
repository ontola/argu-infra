variable workers {
  description = "Map of kubernetes workers."
  type = list(object({
    service         = string
    image_name      = string
    component       = string
    command         = list(string)
    databases       = list(string)
  }))

  default = [
    {
      service = "apex"
      component = "worker"
      image_name = "apex"
      command = ["bundle", "exec", "sidekiq"]
      databases = [
        "elasticsearch",
        "postgresql",
        "redis",
        "rabbitmq",
      ]
    },
    {
      service = "email"
      component = "worker"
      image_name = "email_service"
      command = ["bundle", "exec", "sidekiq"]
      databases = [
        "postgresql",
        "redis",
        "rabbitmq",
      ]
    },
    {
      service = "email"
      component = "subscriber"
      image_name = "email_service"
      command = ["bundle", "exec", "rake", "broadcast:subscribe"]
      databases = [
        "postgresql",
        "redis",
        "rabbitmq",
      ]
    },
    {
      service = "token"
      component = "worker"
      image_name = "token_service"
      command = ["bundle", "exec", "sidekiq"]
      databases = [
        "postgresql",
        "redis",
        "rabbitmq",
      ]
    },
  ]
}

resource "kubernetes_deployment" "worker-deployments" {
  for_each = {for worker in var.workers:  "${worker.service}-${worker.component}" => worker}

  metadata {
    name = "${each.key}-dep"
    annotations = {
      "service-name": each.value.service
      "reloader.stakater.com/auto": "true"
    }
  }

  spec {
    revision_history_limit = 2
    replicas = var.cluster_env == "production" ? 0 : 1

    selector {
      match_labels = {
        app: var.application_name
        tier: each.value.service
        component: each.value.component
      }
    }

    template {
      metadata {
        labels = {
          app: var.application_name
          tier: each.value.service
          component: each.value.component
        }
      }
      spec {
        image_pull_secrets {
          name = kubernetes_secret.container-registry-secret.metadata[0].name
        }
        container {
          name = each.key
          image = "${var.image_registry}/${var.image_registry_org}/${each.value.image_name}:${try(var.service_image_tag[each.value.service], var.image_tag)}"
          command = each.value.command

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
              name = "wt-configmap-${each.value.service}"
            }
          }
          env_from {
            secret_ref {
              name = "wt-secret-${each.value.service}"
            }
          }

          dynamic "env_from" {
            for_each = each.value.databases

            content {
              secret_ref {
                name = "wt-secret-db-${env_from.value}"
              }
            }
          }
        }
      }
    }
  }
}
