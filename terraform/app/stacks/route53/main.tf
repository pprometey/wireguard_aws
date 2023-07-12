# This is where you put your resource declaration
resource "aws_route53_record" "wireguard" {
  zone_id = var.hosted_zone_id
  name    = var.public_dns
  type    = "CNAME"
  ttl     = "300"
  records = [var.lb_dns]
}