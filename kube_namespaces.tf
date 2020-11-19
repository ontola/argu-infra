resource "kubernetes_namespace" "system" {
  metadata {
    name = var.system_namespace
    labels = {
      "certmanager.k8s.io/disable-validation" = "true"
    }
  }
}
