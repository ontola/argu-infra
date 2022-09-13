locals {
  mailcatcher-domain = var.enable_mailcatcher == true ? "${kubernetes_service.service-mailcatcher[0].metadata[0].name}.${local.full_base_domain}" : ""
}

resource "kubernetes_deployment" "deployment-mailcatcher" {
  count = var.enable_mailcatcher ? 1 : 0

  metadata {
    name      = "mailcatcher-dep"
    namespace = kubernetes_namespace.this.metadata[0].name
    annotations = {
      "service-name" : "mailcatcher"
      "reloader.stakater.com/auto" : "true"
    }
  }

  spec {
    revision_history_limit = 2
    replicas               = 1

    selector {
      match_labels = {
        app : var.application_name
        tier : "mailcatcher"
        component : "server"
      }
    }

    template {
      metadata {
        labels = {
          app : var.application_name
          tier : "mailcatcher"
          component : "server"
        }
      }
      spec {
        container {
          name  = "mailcatcher"
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
  count = var.enable_mailcatcher == true ? 1 : 0

  metadata {
    name = "mailcatcher"
    namespace = kubernetes_namespace.this.metadata[0].name
    annotations = {
      "service-name" = "mailcatcher"
    }
    labels = {
      app : var.application_name
      tier : "mailcatcher"
      component : "server"
    }
  }

  spec {
    type = "NodePort"

    port {
      name        = "web"
      port        = 1080
      target_port = 1080
    }

    port {
      name        = "smtp"
      port        = 1025
      target_port = 1025
    }

    selector = {
      app : var.application_name
      tier : "mailcatcher"
      component : "server"
    }
  }
}
