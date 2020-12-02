variable services {
  description = "Map of kubernetes services."
  type = map(object({
    service_name    = string
    image_name      = string
    container_port  = number
    port            = number
    replicas        = number
    scrape          = bool
    databases       = list(string)
  }))

  default = {
    apex = {
      service_name = "argu"
      image_name = "apex"
      container_port = 3000
      port = 3000
      replicas = 1
      scrape = false
      databases = [
        "elasticsearch",
        "postgresql",
        "redis",
        "rabbitmq",
      ]
    },
    cache = {
      service_name = "apex-rs"
      image_name = "apex-rs"
      container_port = 3030
      port = 3030
      replicas = 1
      scrape = true
      databases = [
        "postgresql",
        "redis",
      ]
    },
    frontend = {
      service_name = "frontend"
      image_name = "libro"
      container_port = 8080
      port = 80
      replicas = 2
      scrape = false
      databases = [
        "redis"
      ]
    },
    email = {
      service_name = "email"
      image_name = "email_service"
      container_port = 3000
      port = 3000
      replicas = 1
      scrape = false
      databases = [
        "postgresql",
        "redis",
        "rabbitmq",
      ]
    },
    token = {
      service_name = "token"
      image_name = "token_service"
      container_port = 3000
      port = 3000
      replicas = 1
      scrape = false
      databases = [
        "postgresql",
        "redis",
        "rabbitmq",
      ]
    },
  }
}

resource "kubernetes_deployment" "service-deployments" {
  for_each = var.services

  metadata {
    name = "${each.key}-dep"
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
        component: "server"
      }
    }

    template {
      metadata {
        labels = {
          app: var.application_name
          tier: each.key
          component: "server"
          "prometheus.io/scrape": each.value.scrape
          "prometheus.io/port": each.value.port
        }
      }
      spec {
        image_pull_secrets {
          name = kubernetes_secret.container-registry-secret.metadata[0].name
        }
        container {
          name = each.key
          image = "${var.image_registry}/${var.image_registry_org}/${each.value.image_name}:${try(var.service_image_tag[each.key], var.image_tag)}"
          port {
            container_port = each.value.container_port
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

resource "kubernetes_service" "service-services" {
  for_each = var.services

  metadata {
    name = each.value.service_name
    annotations = {
      "service-name" = each.key
    }
    labels = {
      app: var.application_name
      tier: each.key
      component: "server"
    }
  }

  spec {
    type = "NodePort"

    port {
      port = each.value.port
      target_port = each.value.container_port
    }

    selector = {
      app: var.application_name
      tier: each.key
      component: "server"
    }
  }
}
