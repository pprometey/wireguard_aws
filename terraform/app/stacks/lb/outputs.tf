# This is where you put your outputs declaration
output "lb_id" {
  value = aws_lb.lb.id
}
output "lb_arn" {
  value = aws_lb.lb.arn
}
output "lb_dns" {
 value = aws_lb.lb.dns_name 
}