resource "aws_acm_certificate" "cert" {
  provider          = aws.useast1
  domain_name       = "omaralqinneh.me"
  validation_method = "DNS"

  tags = {
    Description = "SSL Certificate for Cloud Resume Challenge"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ceating dns record for validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true #allows overwriting existing validation records
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

# wait until cert is validated  
resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.useast1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}