terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.18.0"
    }

    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "~> 2.0.0"
    }

    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.2.0"
    }

    helm = {
      source = "hashicorp/helm"
      version = "~> 1.3.2"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 1.13.3"
    }

    kubernetes-alpha = {
      source = "hashicorp/kubernetes-alpha"
      version = "~> 0.2.1"
    }

    random = {
      source = "hashicorp/random"
      version = "~> 3.0.0"
    }

    tls = {
      source = "hashicorp/tls"
      version = "~> 3.0.0"
    }

    template = {
      source = "hashicorp/template"
      version = "~> 2.2.0"
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
