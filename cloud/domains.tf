locals {
  default_prefix = var.cluster_env == "production" ? "" : "${var.cluster_env}."
  domain_prefix  = coalesce(var.env_domain_prefix, local.default_prefix)

  # The base domain and the prefix, eg staging.argu.co
  full_base_domain = join("", [var.env_domain_prefix, var.base_domain])

  # Map of zone names to prefixed names
  domains = merge(
    { (local.full_base_domain) : local.full_base_domain },
    (var.cluster_env != "staging"
      ? { for domain in var.managed_domains : domain => domain }
      : { for domain in var.managed_domains : domain => "${var.env_domain_prefix}${domain}" }
    )
  )
}

resource "digitalocean_domain" "this" {
  for_each = local.domains

  name = each.value
}

resource "digitalocean_record" "root" {
  for_each = local.domains

  domain = digitalocean_domain.this[each.key].id
  type   = "A"
  name   = "@"
  ttl    = 60
  value  = data.digitalocean_loadbalancer.this.ip
}

resource "digitalocean_record" "caa" {
  for_each = local.domains

  domain = digitalocean_domain.this[each.key].id
  type   = "CAA"
  name   = "@"
  ttl    = 60
  flags  = 0
  tag    = "issue"
  value  = "letsencrypt.org."
}

resource "digitalocean_record" "www" {
  for_each = local.domains

  domain = digitalocean_domain.this[each.key].id
  type   = "CNAME"
  name   = "www"
  ttl    = 60
  value  = "demogemeente.nl."
}

resource "digitalocean_record" "analytics" {
  for_each = local.domains

  domain = digitalocean_domain.this[each.key].id
  type   = "CNAME"
  name   = var.analytics_subdomain
  ttl    = 60
  value  = format("%s.", each.value)
}

locals {
  automated_domain_records = flatten(concat(
    values(digitalocean_record.root)[*].fqdn,
    values(digitalocean_record.www)[*].fqdn,
    values(digitalocean_record.analytics)[*].fqdn,
  ))
}
