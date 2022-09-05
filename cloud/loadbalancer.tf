locals {
  used_issuer = (var.letsencrypt_issuers == true
    ? (var.letsencrypt_env_production == true
      ? kubernetes_manifest.letsencrypt-prod-issuer[0].manifest.metadata.name
    : kubernetes_manifest.letsencrypt-staging-issuer[0].manifest.metadata.name)
    : ""
  )
}

data "digitalocean_loadbalancer" "this" {
  name = local.cluster_name
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
