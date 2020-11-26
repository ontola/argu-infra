locals {
  domains = [
    "particidam.nl",
  ]
}

resource "aws_route53_delegation_set" "this" {

}

resource "aws_route53_zone" "this" {
  for_each = toset(local.domains)
  delegation_set_id = aws_route53_delegation_set.this.id

  name = each.value
}

resource "aws_route53_record" "apex_a" {
  for_each = toset(local.domains)

  zone_id = aws_route53_zone.this[each.value].zone_id
  name    = each.value
  type    = "A"
  ttl = 60
  records = [
    kubernetes_ingress.default-ingress.load_balancer_ingress[0].ip
  ]
}

resource "aws_route53_record" "apex_aaaa" {
  for_each = toset(local.domains)

  zone_id = aws_route53_zone.this[each.value].zone_id
  name    = each.value
  type    = "AAAA"
  ttl = 60
  records = [
    digitalocean_droplet.haproxy.ipv6_address
  ]
}
