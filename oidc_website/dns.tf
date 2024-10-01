# This file configures DNS in Route 53. The first part is about
# certificate validation. It just gets all the records from the
# newly created ACM certificate and pushes them to Route 53.
# The second part is pointing our domain to CloudFront.

data "aws_route53_zone" "zone" {
  name     = var.zone_domain_name
  count    = var.zone_domain_name == "" ? 0 : 1
}

## Validate certificate
resource "aws_route53_record" "cert_validation" {
  for_each = var.zone_domain_name != "" ? {
    for dvo in aws_acm_certificate.cert[0].domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.zone[0].zone_id
      record  = dvo.resource_record_value
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  zone_id         = each.value.zone_id
  records         = [each.value.record]
  ttl             = 60
}

## Point domain to CloudFront
resource "aws_route53_record" "oidc_website" {
  zone_id = data.aws_route53_zone.zone[0].zone_id
  count   = var.domain_name != "" ? 1 : 0
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}