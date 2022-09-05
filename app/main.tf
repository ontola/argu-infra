terraform {
  experiments = [
    module_variable_optional_attrs,
  ]
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.app_namespace
  }
}

output "namespace" {
  value = kubernetes_namespace.this.metadata[0].name
}
