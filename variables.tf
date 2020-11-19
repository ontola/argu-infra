variable "letsencrypt_email" {
  type = string
}

variable "system_namespace" {
  type = string
  default = "c66-system"
}

variable "cluster_host" {
  type = string
}

variable "do_token" {
  type = string
}

variable "cluster_credentials" {
  type = object({
    username = string
    password = string
  })
}
