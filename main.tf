terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "1.13.3"
    }

    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.2.0"
    }

    helm = {
      source = "hashicorp/helm"
      version = "1.3.2"
    }
  }

  backend "remote" {
    hostname = "app.terraform.io"
    organization = "ontola"

    workspaces {
      name = "ontola"
    }
  }
}

resource "random_pet" "tfc_refresh" {
  keepers = {
    refresh : 1
  }
}
