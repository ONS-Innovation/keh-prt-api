data "aws_route53_zone" "domain" {
  name = "${var.domain}.${var.domain_extension}"
}