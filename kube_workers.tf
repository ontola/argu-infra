variable workers {
  description = "Map of kubernetes workers."
  type = map(object({
    image_name      = string
    command         = list(string)
    replicas        = number
    databases       = list(string)
  }))

  default = {
    apex = {
      image_name = "apex"
      command = ["bundle", "exec", "sidekiq"]
      replicas = 1
      databases = [
        "elasticsearch",
        "postgresql",
        "redis",
      ]
    },
    cache = {
      image_name = "apex-rs"
      command = ["/usr/local/bin/invalidator_redis"]
      replicas = 1
      databases = [
        "postgresql",
        "redis",
      ]
    },
  }
}

resource "kubernetes_deployment" "worker-deployments" {
  for_each = var.workers

  metadata {
    name = "${each.key}-worker-dep"
    annotations = {
      "service-name": each.key
    }
  }

  spec {
    revision_history_limit = 2
    replicas = each.value.replicas

    selector {
      match_labels = {
        app: var.application_name
        tier: each.key
        component: "worker"
      }
    }

    template {
      metadata {
        labels = {
          app: var.application_name
          tier: each.key
          component: "worker"
        }
      }
      spec {
        image_pull_secrets {
          name = kubernetes_secret.container-registry-secret.metadata[0].name
        }
        container {
          name = each.key
          image = "${var.image_registry}/${var.image_registry_org}/${each.value.image_name}:${try(var.service_image_tag[each.key], var.image_tag)}"
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
              name = "wt-configmap-${each.key}"
            }
          }
          env_from {
            secret_ref {
              name = "wt-secret-${each.key}"
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
