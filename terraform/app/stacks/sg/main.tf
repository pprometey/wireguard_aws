# This is where you put your resource declaration
resource "aws_security_group" "sg_wireguard" {
  name        = "wireguard-${var.ts_env}"
  description = "Terraform Managed. Allow Wireguard client traffic from internet."
  vpc_id      = var.vpc_id

  tags = {
    Name       = "wireguard-${var.ts_env}"
    tf-managed = "True"
  }

  ingress {
    from_port   = var.wg_server_port
    to_port     = var.wg_server_port
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "internal" {
    type        = "ingress"
    from_port   = 0
    to_port     = 65535
    protocol    = "all"
    source_security_group_id = aws_security_group.sg_wireguard.id
    security_group_id = aws_security_group.sg_wireguard.id
}