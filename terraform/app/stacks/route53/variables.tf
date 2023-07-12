# This is where you put your variables declaration
variable "hosted_zone_id" {
  default = "Z02211833S55GC0JC584X"
  description = "Hosted zone id"
  type = string
}

variable "lb_dns" {}

variable "public_dns" {
  type = string
  description = "Public DNS for the route53 record"
  default = "wireguard.trafilea.io"
}