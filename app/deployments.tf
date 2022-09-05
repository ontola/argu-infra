
resource "kubernetes_deployment" "service-deployments" {
  for_each = var.services

  metadata {
    name      = "${each.key}-dep"
    namespace = kubernetes_namespace.this.metadata[0].name
    annotations = {
      "service-name" : each.key
      "reloader.stakater.com/auto" : "true"
    }
  }

  spec {
    revision_history_limit = 2
    replicas               = each.value.replicas

    selector {
      match_labels = {
        app : var.application_name
        tier : each.key
        component : "server"
      }
    }

    template {
      metadata {
        labels = {
          app : var.application_name
          tier : each.key
          component : "server"
          "prometheus.io/scrape" : each.value.scrape
          "prometheus.io/port" : each.value.port
        }
      }
      spec {
        image_pull_secrets {
          name = kubernetes_secret.container-registry-secret.metadata[0].name
        }

        container {
          name    = each.key
          image   = "${each.value.image}:${try(var.service_image_tag[each.key], var.image_tag)}"
          command = each.value.command
          port {
            container_port = each.value.container_port
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
      }
    }
  }
}

resource "kubernetes_service" "service-services" {
  for_each = var.services

  metadata {
    name      = each.value.service_name
    namespace = kubernetes_namespace.this.metadata[0].name
    annotations = {
      "service-name" = each.key
    }
    labels = {
      app : var.application_name
      tier : each.key
      component : "server"
    }
  }

  spec {
    type = "NodePort"

    port {
      port        = each.value.port
      target_port = each.value.container_port
    }

    selector = {
      app : var.application_name
      tier : each.key
      component : "server"
    }
  }
}
