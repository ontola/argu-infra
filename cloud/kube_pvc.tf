
resource "kubernetes_persistent_volume_claim" "wt-volume-claim-matomo-html" {
  metadata {
    name = "wt-volume-claim-matomo-html"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    storage_class_name = "do-block-storage"

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }

  wait_until_bound = true
}
