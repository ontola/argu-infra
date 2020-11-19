provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_kubernetes_cluster" "k8s-ams3-ontola-apex-1" {
  name = "k8s-ams3-ontola-2"
  region = "ams3"
  version = "1.19.3-do.2"
  tags = [
    "argu-staging",
    "staging",
  ]

  node_pool {
    name = "pool-gp-curious-cougar"
    size = "g-2vcpu-8gb"
    node_count = 1
    auto_scale = false
  }
}
