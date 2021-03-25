terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.18.0"
    }

    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.6.0"
    }

    helm = {
      source = "hashicorp/helm"
      version = "~> 2.0.3"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.0.3"
    }

    kubernetes-alpha = {
      source = "hashicorp/kubernetes-alpha"
      version = "~> 0.3.2"
    }

    random = {
      source = "hashicorp/random"
      version = "~> 3.1.0"
    }

    tls = {
      source = "hashicorp/tls"
      version = "~> 3.1.0"
    }
  }

  backend "remote" {
    hostname = "app.terraform.io"
    organization = "ontola"

    workspaces {
      prefix = "ontola-"
    }
  }
}

resource "random_pet" "tfc_refresh" {
  keepers = {
    refresh : 1
  }
}
