
resource "kubernetes_stateful_set" "service-deployments" {
  for_each = var.stateful_sets

  metadata {
    name = "${each.key}-dep"
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

        dynamic "volume" {
          for_each = coalesce(each.value.volumes, {})

          content {
            name = "volume-${each.key}-${volume.key}"

            persistent_volume_claim {
              claim_name = kubernetes_persistent_volume_claim.wt-volume-claim-matomo-html.metadata[0].name
            }
          }
        }

        container {
          name  = each.key
          image = each.value.image

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
            for_each = coalesce(each.value.databases, [])

            content {
              secret_ref {
                name = "wt-secret-db-${env_from.value}"
              }
            }
          }

          dynamic "volume_mount" {
            for_each = coalesce(each.value.volumes, {})

            content {
              name       = "volume-${each.key}-${volume_mount.key}"
              mount_path = volume_mount.value
            }
          }
        }
      }
    }
    service_name = ""
  }
}

resource "kubernetes_service" "stateful-set-services" {
  for_each = var.stateful_sets

  metadata {
    name = each.value.service_name
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
