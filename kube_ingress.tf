resource "kubernetes_ingress" "default-ingress" {
  metadata {
    name = "default-ingress"
    annotations = {
      "cert-manager.io/cluster-issuer": "cert-manager-cluster-issuer"
      "acme.cert-manager.io/http01-edit-in-place": "true"
      "service.beta.kubernetes.io/do-loadbalancer-healthcheck-path": kubernetes_deployment.default-http-backend.spec[0].template[0].spec[0].container[0].liveness_probe[0].http_get[0].path
      "service.beta.kubernetes.io/do-loadbalancer-healthcheck-protocol": "http"
      "service.beta.kubernetes.io/do-loadbalancer-enable-proxy-protocol": "true"
    }
  }

  spec {
    backend {
      service_name = kubernetes_deployment.default-http-backend.metadata[0].name
      service_port = "80"
    }

    rule {
      http {
        path {
          path = "/link-lib"
          backend {
            service_name = kubernetes_service.service-services[local.cache_provider_service].metadata[0].name
            service_port = var.services.cache.port
          }
        }

        path {
          path = "/"
          backend {
            service_name = "frontend"
            service_port = var.services.frontend.port
          }
        }
      }
    }
  }
}
