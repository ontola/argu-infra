locals {
  jwt_encryption_token = coalesce(var.env_jwt_encryption_token, random_password.jwt-encryption-token.result)
  secret_token         = coalesce(var.env_secret_token, random_password.secret-token.result)
  secret_key_base      = coalesce(var.env_secret_key_base, random_password.secret-key-base.result)
}

resource "random_password" "jwt-encryption-token" {
  length  = 128
  special = false
}

resource "random_password" "secret-token" {
  length  = 128
  special = false
}

resource "random_password" "secret-key-base" {
  length  = 128
  special = false
}

resource "random_password" "devise-secret" {
  length  = 128
  special = false
}

resource "random_password" "devise-pepper" {
  length  = 128
  special = false
}
