terraform {
  experiments = [
    module_variable_optional_attrs,
  ]

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.28.0"
    }

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.22.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.6.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.13.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.2"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.1"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "ontola"

    workspaces {
      prefix = "ontola-"
    }
  }
}

data "terraform_remote_state" "shared" {
  backend = "remote"

  config = {
    hostname     = "app.terraform.io"
    organization = "ontola"

    workspaces = {
      name = "shared"
    }
  }
}

resource "random_pet" "tfc_refresh" {
  keepers = {
    refresh : 1
  }
}
