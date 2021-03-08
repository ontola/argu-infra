
resource "kubernetes_deployment" "default-http-backend" {
  metadata {
    name = "default-http-backend"
    labels = {
      k8s-app = "default-http-backend"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        k8s-app = "default-http-backend"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "default-http-backend"
        }
      }

      spec {
        termination_grace_period_seconds = 60

        container {
          image = "gcr.io/google_containers/defaultbackend:1.4"
          name  = "default-http-backend"

          resources {
            requests {
              cpu    = "10m"
              memory = "20Mi"
            }
            limits {
              cpu    = "10m"
              memory = "20Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }

            initial_delay_seconds = 30
            timeout_seconds = 5
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "default-http-backend" {
  metadata {
    name = "default-http-backend"
    labels = {
      k8s-app = "default-http-backend"
    }
  }

  spec {
    port {
      port = "80"
      target_port = "8080"
    }

    selector = {
      k8s-app = "default-http-backend"
    }
  }
}
