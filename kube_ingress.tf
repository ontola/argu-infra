locals {
  ingress_tls_hosts = list(
    "kube.staging.argu.co",
    "v6.kube.staging.argu.co",
    "kube.staging.demogemeente.nl",
  )
}

resource "kubernetes_manifest" "letsencrypt-staging-issuer" {
  provider = kubernetes-alpha

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-staging-issuer"
    }
    spec = {
      acme = {
        # You must replace this email address with your own.
        # Let's Encrypt will use this to contact you about expiring
        # certificates, and issues related to your account.
        email = var.letsencrypt_email
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          # Secret resource that will be used to store the account's private key.
          name = "letsencrypt-staging-account-key"
        }
        # Add a single challenge solver, HTTP01 using nginx
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "letsencrypt-prod-issuer" {
  provider = kubernetes-alpha

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod-issuer"
    }
    spec = {
      acme = {
        # You must replace this email address with your own.
        # Let's Encrypt will use this to contact you about expiring
        # certificates, and issues related to your account.
        email = var.letsencrypt_email
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          # Secret resource that will be used to store the account's private key.
          name = "letsencrypt-prod-account-key"
        }
        # Add a single challenge solver, HTTP01 using nginx
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]
      }
    }
  }
}

resource "kubernetes_config_map" "custom-headers" {
  metadata {
    name = "nginx-custom-headers"
    namespace = "default"
  }

  data = {
    "X-Powered-By": "Ontola.io"
  }
}

resource "kubernetes_ingress" "default-ingress" {
  wait_for_load_balancer = true

  metadata {
    name = "default-ingress"
    annotations = {
      "cert-manager.io/cluster-issuer": kubernetes_manifest.letsencrypt-prod-issuer.manifest.metadata.name
      "acme.cert-manager.io/http01-edit-in-place": "true"
      "service.beta.kubernetes.io/do-loadbalancer-healthcheck-path": kubernetes_deployment.default-http-backend.spec[0].template[0].spec[0].container[0].liveness_probe[0].http_get[0].path
      "service.beta.kubernetes.io/do-loadbalancer-healthcheck-protocol": "http"
      "service.beta.kubernetes.io/do-loadbalancer-enable-proxy-protocol": "true"
      "nginx.ingress.kubernetes.io/server-alias": join(",", local.ingress_tls_hosts)
    }
  }

  spec {
    backend {
      service_name = kubernetes_deployment.default-http-backend.metadata[0].name
      service_port = "80"
    }

    rule {
      host = local.ingress_tls_hosts[0]
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

    tls {
      secret_name = "tls"
      hosts = local.ingress_tls_hosts
    }
  }
}
