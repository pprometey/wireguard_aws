# This is where you put your resource declaration
resource "aws_efs_file_system" "efs" {
  creation_token = "wireguard-efs"
  encrypted = true
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

resource "aws_efs_mount_target" "mount_target" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = "subnet-0fb92c6d930240664"
  security_groups = [var.wireguard_sg]
}