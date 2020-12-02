variable workers {
  description = "Map of kubernetes workers."
  type = list(object({
    service         = string
    image_name      = string
    component       = string
    command         = list(string)
    replicas        = number
    databases       = list(string)
  }))

  default = [
    {
      service = "apex"
      component = "worker"
      image_name = "apex"
      command = ["bundle", "exec", "sidekiq"]
      replicas = 1
      databases = [
        "elasticsearch",
        "postgresql",
        "redis",
        "rabbitmq",
      ]
    },
    {
      service = "cache"
      component = "worker"
      image_name = "apex-rs"
      command = ["/usr/local/bin/invalidator_redis"]
      replicas = 1
      databases = [
        "postgresql",
        "redis",
      ]
    },
    {
      service = "email"
      component = "worker"
      image_name = "email_service"
      command = ["bundle", "exec", "sidekiq"]
      replicas = 1
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
      replicas = 1
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
      replicas = 1
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
    }
  }

  spec {
    revision_history_limit = 2
    replicas = each.value.replicas

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
