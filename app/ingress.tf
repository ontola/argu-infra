locals {
  studio_domain = join("", [var.env_domain_prefix, "rdf.studio"])

  mailcatcher_domains = var.enable_mailcatcher == true ? (
    compact([
      local.mailcatcher-domain,
    ])
    ) : (
    []
  )

  website_domains = distinct(concat(
    var.all_domains,
    var.custom_simple_domains,
    [local.studio_domain],
  ))

  ingress_tls_hosts = distinct(concat(
    var.all_domains,
    var.analytics_domains,
    local.mailcatcher_domains,
    var.custom_simple_domains,
    [local.studio_domain],
  ))

  whitelist_source_range = var.ip_whitelist == null ? "0.0.0.0/0" : var.ip_whitelist
}

resource "kubernetes_ingress_v1" "default-ingress" {
  wait_for_load_balancer = true

  metadata {
    name      = "default-ingress"
    namespace = kubernetes_namespace.this.metadata[0].name
    annotations = {
      "cert-manager.io/cluster-issuer" : var.used_issuer
      "service.beta.kubernetes.io/do-loadbalancer-healthcheck-path" : kubernetes_deployment.default-http-backend.spec[0].template[0].spec[0].container[0].liveness_probe[0].http_get[0].path
      "service.beta.kubernetes.io/do-loadbalancer-healthcheck-protocol" : "http"
      "service.beta.kubernetes.io/do-loadbalancer-enable-proxy-protocol" : "true"
      "nginx.ingress.kubernetes.io/body-size" : "1024m"
      "nginx.ingress.kubernetes.io/client-body-buffer-size" : "50m"
      "nginx.ingress.kubernetes.io/client-max-body-size" : "50m"
      "nginx.ingress.kubernetes.io/proxy-body-size" : "1024m"
      "nginx.ingress.kubernetes.io/proxy-buffers-number" : 8
      "nginx.ingress.kubernetes.io/proxy-buffer-size" : "1024m"
      "nginx.ingress.kubernetes.io/proxy-max-temp-file-size" : "1024m"
      "nginx.ingress.kubernetes.io/server-alias" : join(",", local.website_domains)
      "nginx.ingress.kubernetes.io/whitelist-source-range" : local.whitelist_source_range
      "kubernetes.io/ingress.class" : "nginx"
    }
  }

  spec {
    default_backend {
      service {
        name = kubernetes_deployment.default-http-backend.metadata[0].name
        port {
          number = "80"
        }
      }
    }

    dynamic "rule" {
      for_each = toset(local.mailcatcher_domains)

      content {
        host = rule.value

        http {
          path {
            path = "/"
            backend {
              service {
                name = kubernetes_service.service-mailcatcher[0].metadata[0].name
                port {
                  number = kubernetes_service.service-mailcatcher[0].spec[0].port[0].port
                }
              }
            }
          }
        }
      }
    }

    dynamic "rule" {
      for_each = local.website_domains

      content {
        host = rule.value

        http {
          path {
            path = "/"
            backend {
              service {
                name = "frontend"
                port {
                  number = var.services.frontend.port
                }
              }
            }
          }
        }
      }
    }


    tls {
      secret_name = "tls"
      hosts       = local.ingress_tls_hosts
    }
  }
}
