resource "random_password" "rabbitmq-password" {
  length = 24
  special = false
}

resource "random_password" "rabbitmq-erlang-cookie" {
  length = 250
  special = false
}

resource "kubernetes_secret" "rabbitmq-credentials" {
  metadata {
    name = "rabbitmq-credentials"
  }

  data = {
    username = "admin"
    "rabbitmq-password" = random_password.rabbitmq-password.result
  }
}

resource "helm_release" "rabbitmq" {
  repository = "https://charts.bitnami.com/bitnami"
  chart = "rabbitmq"
  name = "rabbitmq"
  version = var.ver_chart_rabbitmq

  cleanup_on_fail = true
  set {
    name = "auth.username"
    value = kubernetes_secret.rabbitmq-credentials.data.username
  }
  set {
    name = "auth.existingPasswordSecret"
    value = kubernetes_secret.rabbitmq-credentials.metadata[0].name
  }
  set {
    name = "service.port"
    value = var.env_rabbitmq_port
  }
  set {
    name = "auth.erlangCookie"
    value = random_password.rabbitmq-erlang-cookie.result
  }
}
