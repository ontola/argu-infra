locals {
  full_base_and_subdomains = [
    local.full_base_domain,
    "www.${local.full_base_domain}",
    //    "v6.${local.full_base_domain}",
  ]

  expanded_managed_domains = flatten([
    for domain in var.managed_domains : [
      join("", [var.env_domain_prefix, domain]),
      "www.${join("", [var.env_domain_prefix, domain])}",
    ]
  ])

  studio_domain = join("", [var.env_domain_prefix, "rdf.studio"])

  analytics_domains = flatten(concat(
    ["analytics.${local.full_base_domain}"],
    [for domain in var.managed_domains : "analytics.${join("", [var.env_domain_prefix, domain])}"],
  ))

  mailcatcher_domains = var.enable_mailcatcher == true ? (
    compact([
      local.mailcatcher-domain,
    ])
    ) : (
    []
  )

  website_domains = distinct(concat(
    local.full_base_and_subdomains,
    local.automated_domain_records,
    local.expanded_managed_domains,
    var.custom_simple_domains,
    [local.studio_domain],
  ))

  ingress_tls_hosts = distinct(concat(
    local.full_base_and_subdomains,
    local.automated_domain_records,
    local.expanded_managed_domains,
    local.analytics_domains,
    local.mailcatcher_domains,
    var.custom_simple_domains,
    [local.studio_domain],
  ))

  used_issuer = (var.letsencrypt_issuers == true
    ? (var.letsencrypt_env_production == true
      ? kubernetes_manifest.letsencrypt-prod-issuer[0].manifest.metadata.name
    : kubernetes_manifest.letsencrypt-staging-issuer[0].manifest.metadata.name)
  : "")
}

resource "kubernetes_manifest" "letsencrypt-staging-issuer" {
  count = var.letsencrypt_issuers == true ? 1 : 0

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-staging-issuer"
    }
    spec = {
      acme = {
        # You must replace this email address with your own.
        # Let's Encrypt will use this to contact you about expiring
        # certificates, and issues related to your account.
        email  = var.letsencrypt_email
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

  depends_on = [
    digitalocean_kubernetes_cluster.k8s-ams3-ontola-apex-1,
    helm_release.cert-manager,
  ]
}

resource "kubernetes_manifest" "letsencrypt-prod-issuer" {
  count = var.letsencrypt_issuers == true ? 1 : 0

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod-issuer"
    }
    spec = {
      acme = {
        # You must replace this email address with your own.
        # Let's Encrypt will use this to contact you about expiring
        # certificates, and issues related to your account.
        email  = var.letsencrypt_email
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

  depends_on = [
    digitalocean_kubernetes_cluster.k8s-ams3-ontola-apex-1,
    helm_release.cert-manager
  ]
}

resource "kubernetes_config_map" "custom-headers" {
  metadata {
    name      = "nginx-custom-headers"
    namespace = "default"
  }

  data = {
    "X-Powered-By" : "Ontola.io"
  }
}

resource "kubernetes_ingress" "default-ingress" {
  wait_for_load_balancer = true

  metadata {
    name = "default-ingress"
    annotations = {
      "cert-manager.io/cluster-issuer" : local.used_issuer
      "service.beta.kubernetes.io/do-loadbalancer-healthcheck-path" : kubernetes_deployment.default-http-backend.spec[0].template[0].spec[0].container[0].liveness_probe[0].http_get[0].path
      "service.beta.kubernetes.io/do-loadbalancer-healthcheck-protocol" : "http"
      "service.beta.kubernetes.io/do-loadbalancer-enable-proxy-protocol" : "true"
      "nginx.ingress.kubernetes.io/server-alias" : join(",", local.website_domains)
      "nginx.ingress.kubernetes.io/whitelist-source-range" : var.ip_whitelist
    }
  }

  spec {
    backend {
      service_name = kubernetes_deployment.default-http-backend.metadata[0].name
      service_port = "80"
    }

    dynamic "rule" {
      for_each = toset(local.mailcatcher_domains)

      content {
        host = rule.value

        http {
          path {
            path = "/"
            backend {
              service_name = kubernetes_service.service-mailcatcher[0].metadata[0].name
              service_port = kubernetes_service.service-mailcatcher[0].spec[0].port[0].port
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
              service_name = "frontend"
              service_port = var.services.frontend.port
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

data "digitalocean_loadbalancer" "this" {
  name = local.cluster_name
}
