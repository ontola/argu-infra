variable "stateful_sets" {
  description = "Map of kubernetes stateful sets."
  type = map(object({
    service_name   = string
    image          = string
    container_port = number
    migrate        = bool
    port           = number
    replicas       = number
    scrape         = bool
    databases      = optional(list(string))
    volumes        = map(string)
  }))

  default = {
    matomo = {
      service_name   = "matomo"
      image          = "matomo:3-apache"
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
