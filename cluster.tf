resource "digitalocean_kubernetes_cluster" "k8s-ams3-ontola-apex-1" {
  name = "k8s-ams3-ontola-2"
  region = "ams3"
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

resource "kubernetes_secret" "container-registry-secret" {
  metadata {
    name = "container-registry-secret"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = "{\"auths\":{\"${var.image_registry}\":{\"username\":\"${var.image_registry_user}\",\"password\":\"${var.image_registry_token}\",\"auth\":\"${base64encode("${var.image_registry_user}:${var.image_registry_token}")}\"}}}"
  }
}

resource "helm_release" "nginx-ingress" {
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  name = "ingress-nginx"
}

resource "helm_release" "elasticsearch" {
  repository = "https://charts.bitnami.com/bitnami"
  chart = "elasticsearch"
  name = "elasticsearch"

  cleanup_on_fail = true
}

resource "helm_release" "prometheus" {
  repository = "https://charts.bitnami.com/bitnami"
  chart = "kube-prometheus"
  name = "prometheus"

  atomic = true
  cleanup_on_fail = true
}

resource "helm_release" "grafana" {
  repository = "https://charts.bitnami.com/bitnami"
  chart = "grafana"
  name = "grafana"

  atomic = true
  cleanup_on_fail = true
}
