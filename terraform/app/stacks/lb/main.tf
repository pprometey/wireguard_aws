# This is where you put your resource declaration
resource "aws_lb" "lb" {
  name                       = "wireguard-lb"
  load_balancer_type         = "network"
  subnets                    = ["subnet-087f86b851460da79", "subnet-0fb92c6d930240664"]
  internal                   = false
  enable_deletion_protection = false
}