variable "services" {
  description = "Map of kubernetes services."
  type = map(object({
    service_name   = string
    override_image = optional(string)
    image_name     = optional(string)
    command        = optional(list(string))
    container_port = number
    migrate        = bool
    port           = number
    replicas       = number
    scrape         = bool
    databases      = optional(list(string))
    volumes        = optional(map(string))
  }))

  default = {
    apex = {
      service_name   = "apex"
      image_name     = "apex"
      container_port = 3000
      migrate        = true
      port           = 3000
      replicas       = 1
      scrape         = false
      databases = [
        "elasticsearch",
        "postgresql",
        "redis",
      ]
    }
    frontend = {
      service_name   = "frontend"
      image_name     = "argu/libro"
      container_port = 3080
      migrate        = false
      port           = 80
      replicas       = 2
      scrape         = false
      databases = [
        "redis"
      ]
    }
    email = {
      service_name   = "email"
      image_name     = "email_service"
      container_port = 3000
      migrate        = true
      port           = 3000
      replicas       = 1
      scrape         = false
      databases = [
        "postgresql",
        "redis",
      ]
    }
    token = {
      service_name   = "token"
      image_name     = "token_service"
      container_port = 3000
      migrate        = true
      port           = 3000
      replicas       = 1
      scrape         = false
      databases = [
        "postgresql",
        "redis",
      ]
    }
    matomo = {
      service_name   = "matomo"
      override_image = "matomo:3-apache"
      container_port = 80
      migrate        = false
      port           = 80
      replicas       = 1
      scrape         = false
      databases = [
        "mysql",
      ]
      volumes = {
        "html" = "/var/www/html"
      }
    }
  }
}
