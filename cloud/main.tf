terraform {
  experiments = [
    module_variable_optional_attrs,
  ]

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.18.0"
    }

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.17.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.4.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.8.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.1.0"
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
