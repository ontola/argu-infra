locals {
  mailcatcher-domain = var.cluster_env != "production" ? "${kubernetes_service.service-mailcatcher[0].metadata[0].name}.${local.full_base_domain}" : ""
}

resource "kubernetes_deployment" "deployment-mailcatcher" {
  count = var.cluster_env != "production" ? 1 : 0

  metadata {
    name = "mailcatcher-dep"
    annotations = {
      "service-name": "mailcatcher"
      "reloader.stakater.com/auto": "true"
    }
  }

  spec {
    revision_history_limit = 2
    replicas = 1

    selector {
      match_labels = {
        app: var.application_name
        tier: "mailcatcher"
        component: "server"
      }
    }

    template {
      metadata {
        labels = {
          app: var.application_name
          tier: "mailcatcher"
          component: "server"
        }
      }
      spec {
        container {
          name = "mailcatcher"
          image = "schickling/mailcatcher:latest"
          port {
            container_port = 1080
          }
          port {
            container_port = 1025
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "service-mailcatcher" {
  count = var.cluster_env != "production" ? 1 : 0

  metadata {
    name = "mailcatcher"
    annotations = {
      "service-name" = "mailcatcher"
    }
    labels = {
      app: var.application_name
      tier: "mailcatcher"
      component: "server"
    }
  }

  spec {
    type = "NodePort"

    port {
      name = "web"
      port = 1080
      target_port = 1080
    }

    port {
      name = "smtp"
      port = 1025
      target_port = 1025
    }

    selector = {
      app: var.application_name
      tier: "mailcatcher"
      component: "server"
    }
  }
}
