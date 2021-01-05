locals {
  # The base domain and the prefix, eg staging.argu.co
  full_base_domain = join("", [var.env_domain_prefix, var.base_domain])

  # Map of zone names to prefixed names
  domains = { for domain in var.automated_domains: domain =>  "${var.env_domain_prefix}${domain}" }
}

resource "aws_route53_delegation_set" "this" {}

resource "aws_route53_zone" "this" {
  for_each = local.domains
  delegation_set_id = aws_route53_delegation_set.this.id

  name = each.key
}

resource "aws_route53_record" "apex_a" {
  for_each = local.domains

  zone_id = aws_route53_zone.this[each.key].zone_id
  name    = each.value
  type    = "A"
  ttl     = 60
  records = [
    kubernetes_ingress.default-ingress.load_balancer_ingress[0].ip
  ]
}

resource "aws_route53_record" "apex_aaaa" {
  for_each = local.domains

  zone_id = aws_route53_zone.this[each.key].zone_id
  name    = each.value
  type    = "AAAA"
  ttl     = 60
  records = [
    digitalocean_droplet.haproxy.ipv6_address
  ]
}

resource "aws_route53_record" "www" {
  for_each = local.domains

  zone_id = aws_route53_zone.this[each.key].zone_id
  name    = format("www.%s", each.value)
  type    = "CNAME"
  ttl     = 60
  records = [each.value]
}

resource "aws_route53_record" "analytics" {
  for_each = local.domains

  zone_id = aws_route53_zone.this[each.key].zone_id
  name    = format("analytics.%s", each.value)
  type    = "CNAME"
  ttl     = 60
  records = [each.value]
}

locals {
  automated_domain_records = flatten(concat(
      values(aws_route53_zone.this)[*].name,
      values(aws_route53_record.www)[*].name,
      values(aws_route53_record.analytics)[*].name,
  ))
}
