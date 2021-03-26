terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.6.0"
    }
  }
}

output "ssh_key_archer" {
  value = digitalocean_ssh_key.archer
}

output "ssh_key_archer_rsa" {
  value = digitalocean_ssh_key.archer_rsa
}
