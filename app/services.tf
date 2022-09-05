variable "services" {
  description = "Map of kubernetes services."
  type = map(object({
    service_name   = string
    image          = optional(string)
    command        = optional(list(string))
    container_port = number
    migrate        = bool
    port           = number
    replicas       = number
    scrape         = bool
    databases      = list(string)
  }))

  default = {
    apex = {
      service_name   = "apex"
      image          = "registry.gitlab.com/ontola/apex"
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
      image          = "argu/libro"
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
      image          = "registry.gitlab.com/ontola/email_service"
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
      image          = "registry.gitlab.com/ontola/token_service"
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
  }
}
