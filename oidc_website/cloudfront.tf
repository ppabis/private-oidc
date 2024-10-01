# This is a pretty standard CloudFront setup. I use the cheapest price class (North America and Europe).
# The only caveats here are aliases and viewer_certificate that are dynamic based if you have given a
# domain name or not. Everything else you can virtually skip if you want to understand what's going on.

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"
  ## Use domain name if it's specified, otherwise use CloudFront default. ##
  aliases             = var.domain_name != "" ? [var.domain_name] : []
  tags                = { Name = "OIDC host website" }
  depends_on          = [aws_route53_record.cert_validation]
  price_class         = "PriceClass_100"

  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    target_origin_id = "S3Origin"

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
  }

  ## If there's domain specificed, use the issued certificate on DNS validation ##
  ## grounds. Otherwise just default to CloudFront's internal certificate.      ##
  dynamic "viewer_certificate" {
    for_each = {
      "" : length(aws_acm_certificate.cert) > 0 ? {
        "cert"        = aws_acm_certificate.cert[0].arn
        "sni"         = "sni-only"
        "tls"         = "TLSv1.2_2021"
        "use_default" = false
        } : {
        "use_default" = true
        cert          = ""
        sni           = null
        tls           = null
      }
    }
    content {
      acm_certificate_arn            = viewer_certificate.value.cert
      ssl_support_method             = viewer_certificate.value.sni
      minimum_protocol_version       = viewer_certificate.value.tls
      cloudfront_default_certificate = viewer_certificate.value.use_default
    }
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

}

# Sign requests to S3 using Origin Access Control
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "OAC_OIDC"
  description                       = "OAC for my OIDC website"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
  origin_access_control_origin_type = "s3"
}

output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

