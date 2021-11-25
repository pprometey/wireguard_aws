# This is where you put your outputs declaration
output "efs_dns" {
  value = aws_efs_mount_target.mount_target.dns_name
}