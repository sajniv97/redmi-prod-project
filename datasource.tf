data "aws_route53_zone" "official" {
  name         = var.domain_name
  private_zone = false
}

