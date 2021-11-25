# This is where you put your resource declaration
resource "aws_lb" "lb" {
  name                       = "wireguard-lb"
  load_balancer_type         = "network"
  subnets                    = ["subnet-087f86b851460da79", "subnet-0fb92c6d930240664"]
  internal                   = false
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "lb_target" {
  name     = "wireguard-target-group"
  port     = 51820
  protocol = "UDP"
  vpc_id   = "vpc-0168c2f02fd3d2027"
  health_check {
    port = 8080
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 51820
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target.arn
  }
}