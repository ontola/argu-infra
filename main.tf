terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.2.0"
    }
  }
}

//provider "kubernetes" {
//  load_config_file = "false"
//
//  host = var.cluster_host
//
//  username = var.cluster_credentials.username
//  password = var.cluster_credentials.password
//}
