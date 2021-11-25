# This is where you put your outputs declaration
output "sg_id" {
  value = aws_security_group.sg_wireguard.id
}