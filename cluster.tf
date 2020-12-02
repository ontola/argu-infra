locals {
  ootb_brotli_types = "application/xml+rss application/atom+xml application/javascript application/x-javascript application/json application/rss+xml application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/svg+xml image/x-icon text/css text/plain text/x-component"
  custom_brotli_types = [
    "application/hex+x-ndjson",
    "application/n-triples",
    "application/n-quads",
    "application/n3",
    "text/turtle",
  ]
}

resource "digitalocean_kubernetes_cluster" "k8s-ams3-ontola-apex-1" {
  name = "k8s-ams3-ontola-2"
  region = var.do_region
  version = "1.19.3-do.2"
  tags = [
    "argu-staging",
    "staging",
    "k8s-ams3-ontola-2",
  ]

  node_pool {
    name = "pool-gp-curious-cougar"
    size = "g-2vcpu-8gb"
    node_count = 1
    auto_scale = false

    tags = [
      "k8s-ams3-ontola-2",
    ]
  }
}

data "template_file" "haproxy_userdata" {
  template = file("${path.module}/config/haproxy_userdata.tpl")
  vars = {
    cluster_ipv4 = kubernetes_ingress.default-ingress.load_balancer_ingress[0].ip,
  }
}

data "cloudinit_config" "haproxy_userdata" {
  gzip = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = data.template_file.haproxy_userdata.rendered
    filename = "haproxy.cloudconfig"
  }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "digitalocean_ssh_key" "this" {
  name = "terraform"
  public_key = tls_private_key.this.public_key_openssh
}

resource "digitalocean_ssh_key" "archer" {
  name = "archer"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDkNoz02B+zy/FEqrsrRMLqMi1OYEWIrl5wl/7g4+TFy fletcher91@fletcher91"
}

resource "digitalocean_ssh_key" "archer_rsa" {
  name = "archer-rsa"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDvc6Zl6mht926qrRDmpntpJYznOa1OeD+Z8kd8ARMgixktTODZQaD5vaBB1ORV+UJpZHe4o4GEI6ercUgli8YqAbXktyBPZYgzkU3k6AqO3j0JkHPPJQYQ+CoqiDl8QgsCh56tXClDnr7Rc0LhVKR3QZO6mCLSUeCL8nLb4oZNPd6cUz2djx6BFp+MtWKFs19VLmmviD9iPdhXz2y1bHjYr1Bs0ESdMEuqVNdpFQOEXBJe/fQW5wGtwi/3/VawwRS03tVnDJYAZ+0M9huibGD2wVM8pGtGBu13EyytfZWuQ/J+Ut8gDTKIgBysd12ks15FfXNpNtB+M30swS7UCLSx fletcher91@fletcher91"
}

resource "digitalocean_droplet" "haproxy" {
  name = "haproxy-${random_pet.tfc_refresh.id}"
  image = "ubuntu-20-04-x64"
  size = "s-1vcpu-1gb"
  region = var.do_region

  ipv6 = true
  monitoring = true
  private_networking = true
  user_data = data.cloudinit_config.haproxy_userdata.rendered
  ssh_keys = [
    digitalocean_ssh_key.this.fingerprint,
    digitalocean_ssh_key.archer.fingerprint,
    digitalocean_ssh_key.archer_rsa.fingerprint,
  ]
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
  chart = "ingress-nginx"
  name = "ingress-nginx"
  version = local.ver_chart_nginx_ingress

  set {
    name = "controller.config.add-headers"
    value = "${kubernetes_config_map.custom-headers.metadata[0].namespace}/${kubernetes_config_map.custom-headers.metadata[0].name}"
  }
  set {
    name = "controller.config.brotli-types"
    value = "${local.ootb_brotli_types} ${join(" ", local.custom_brotli_types)}"
  }
  set {
    type = "string"
    name = "controller.config.enable-brotli"
    value = true
  }
  set {
    type = "string"
    name = "controller.config.enable-modsecurity"
    value = true
  }
  set {
    type = "string"
    name = "controller.config.enable-ocsp"
    value = true
  }
  set {
    type = "string"
    name = "controller.config.enable-owasp-modsecurity-crs"
    value = true
  }
  set {
    name = "controller.config.proxy-body-size"
    value = "250m"
  }
}

resource "helm_release" "cert-manager" {
  repository = "https://charts.jetstack.io"
  chart = "cert-manager"
  name = "cert-manager"
  version = local.ver_chart_cert_manager

  set {
    name = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "elasticsearch" {
  repository = "https://charts.bitnami.com/bitnami"
  chart = "elasticsearch"
  name = "elasticsearch"
  version = local.ver_chart_elasticsearch

  cleanup_on_fail = true
}

resource "kubernetes_secret" "prometheus-config" {
  metadata {
    name = "prometheus-config"
    namespace = "default"
  }

  data = {
    "prometheus.yml" = file("./config/prometheus.yml")
  }
}

resource "helm_release" "prometheus" {
  repository = "https://charts.bitnami.com/bitnami"
  chart = "kube-prometheus"
  name = "prometheus"
  version = local.ver_chart_prometheus

  atomic = true
  cleanup_on_fail = true
  set {
    name = "prometheus.additionalScrapeConfigsExternal.enabled"
    value = "true"
  }
  set {
    name = "prometheus.additionalScrapeConfigsExternal.name"
    value = kubernetes_secret.prometheus-config.metadata[0].name
  }
  set {
    name = "prometheus.additionalScrapeConfigsExternal.key"
    value = "prometheus.yml"
  }
  set {
    name = "prometheus.enableAdminAPI"
    value = "true"
  }
}

resource "helm_release" "grafana" {
  repository = "https://charts.bitnami.com/bitnami"
  chart = "grafana"
  name = "grafana"
  version = local.ver_chart_grafana

  atomic = true
  cleanup_on_fail = true
}
