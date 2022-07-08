resource "aws_route53_record" "avail" {
  zone_id = var.route53_zone_id
  name    = var.route53_domain_name
  type    = "CNAME"
  ttl     = "60"
  records = [aws_lb.avail_nodes.dns_name]
}

resource "aws_acm_certificate" "avail_cert" {
  domain_name       = var.route53_domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "avail_validation" {
  for_each = {
    for dvo in aws_acm_certificate.avail_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
}

resource "aws_acm_certificate_validation" "avail" {
  certificate_arn         = aws_acm_certificate.avail_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.avail_validation : record.fqdn]
}
