locals {
  ootb_brotli_types = "application/xml+rss application/atom+xml application/javascript application/x-javascript application/json application/rss+xml application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/svg+xml image/x-icon text/css text/plain text/x-component"
  custom_brotli_types = [
    "application/empathy+json",
    "application/empathy+x-ndjson",
    "application/hex+x-ndjson",
    "application/n-triples",
    "application/n-quads",
    "application/n3",
    "text/turtle",
  ]

  cluster_name = var.cluster_env != "staging" ? "k8s-${var.do_region}-${var.organization}-${var.cluster_env}-${var.cluster_version}" : "k8s-ams3-ontola-2"

  prometheus_name = (
    var.enable_prometheus
    ? { key = kubernetes_secret.prometheus-config[0].metadata[0].name }
    : {}
  )
}

resource "random_pet" "node_pool" {
  keepers = {
    refresh : 1
  }
}

resource "digitalocean_kubernetes_cluster" "k8s-ams3-ontola-apex-1" {
  name    = local.cluster_name
  region  = var.do_region
  version = var.cluster_env != "staging" ? "1.20.2-do.0" : "1.19.15-do.0"
  tags = [
    "argu-${var.cluster_env}",
    var.cluster_env,
    local.cluster_name,
  ]

  lifecycle {
    ignore_changes = [version]
  }

  node_pool {
    name       = var.cluster_env != "staging" ? "pool-gp-${random_pet.node_pool.id}" : "pool-gp-curious-cougar"
    size       = "g-2vcpu-8gb"
    node_count = 2
    auto_scale = false

    tags = [
      local.cluster_name,
    ]
  }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "digitalocean_ssh_key" "this" {
  name       = "terraform"
  public_key = tls_private_key.this.public_key_openssh
}

resource "kubernetes_secret" "container-registry-secret" {
  metadata {
    name = "container-registry-secret"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = "{\"auths\":{\"${var.image_registry}\":{\"username\":\"${var.image_registry_user}\",\"password\":\"${var.image_registry_token}\",\"auth\":\"${base64encode("${var.image_registry_user}:${var.image_registry_token}")}\"}}}"
  }
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "nginx-ingress" {
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  name       = "ingress-nginx"
  version    = var.ver_chart_nginx_ingress

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-enable-proxy-protocol"
    value = tostring("true")
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-healthcheck-protocol"
    value = "http"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-name"
    value = local.cluster_name
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-healthcheck-path"
    value = kubernetes_deployment.default-http-backend.spec[0].template[0].spec[0].container[0].liveness_probe[0].http_get[0].path
  }
  set {
    name  = "controller.config.add-headers"
    value = "${kubernetes_config_map.custom-headers.metadata[0].namespace}/${kubernetes_config_map.custom-headers.metadata[0].name}"
  }
  set {
    name  = "controller.config.brotli-types"
    value = "${local.ootb_brotli_types} ${join(" ", local.custom_brotli_types)}"
  }
  set {
    type  = "string"
    name  = "controller.config.enable-brotli"
    value = true
  }
  set {
    type  = "string"
    name  = "controller.config.enable-modsecurity"
    value = true
  }
  set {
    type  = "string"
    name  = "controller.config.enable-ocsp"
    value = true
  }
  set {
    type  = "string"
    name  = "controller.config.hsts"
    value = true
  }
  set {
    type  = "string"
    name  = "controller.config.hsts-include-subdomains"
    value = true
  }
  set {
    type  = "string"
    name  = "controller.config.hsts-max-age"
    value = "31536000"
  }
  set {
    type  = "string"
    name  = "controller.config.enable-owasp-modsecurity-crs"
    value = true
  }
  set {
    name  = "controller.config.proxy-body-size"
    value = "250m"
  }
  set {
    name  = "controller.config.use-proxy-protocol"
    value = true
  }
}

resource "helm_release" "cert-manager" {
  description = "https://artifacthub.io/packages/helm/jetstack/cert-manager"
  repository  = "https://charts.jetstack.io"
  chart       = "cert-manager"
  name        = "cert-manager"
  version     = var.ver_chart_cert_manager

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "elasticsearch" {
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "elasticsearch"
  name       = "elasticsearch"
  version    = var.ver_chart_elasticsearch

  cleanup_on_fail = true
}

resource "kubernetes_secret" "prometheus-config" {
  count = var.enable_prometheus ? 1 : 0

  metadata {
    name      = "prometheus-config"
    namespace = "default"
  }

  data = {
    "prometheus.yml" = file("./config/prometheus.yml")
  }
}

resource "helm_release" "prometheus" {
  count = var.enable_prometheus ? 1 : 0

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kube-prometheus"
  name       = "prometheus"
  version    = var.ver_chart_prometheus

  atomic          = true
  cleanup_on_fail = true
  set {
    name  = "prometheus.additionalScrapeConfigs.enabled"
    value = "true"
  }
  set {
    name  = "prometheus.additionalScrapeConfigs.type"
    value = "external"
  }
  set {
    name  = "prometheus.additionalScrapeConfigs.external.key"
    value = "prometheus.yml"
  }
  set {
    name  = "prometheus.enableAdminAPI"
    value = "true"
  }
  dynamic "set" {
    for_each = local.prometheus_name

    content {
      name  = "prometheus.additionalScrapeConfigs.external.name"
      value = set.value
    }
  }
}

resource "helm_release" "grafana" {
  count = var.enable_prometheus ? 1 : 0

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "grafana"
  name       = "grafana"
  version    = var.ver_chart_grafana

  atomic          = true
  cleanup_on_fail = true
}

resource "helm_release" "configmap-reloader" {
  repository = "https://stakater.github.io/stakater-charts"
  chart      = "reloader"
  name       = "reloader"

  atomic          = true
  cleanup_on_fail = true
}
