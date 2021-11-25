# This is where you put your resource declaration
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_launch_configuration" "wireguard_launch_config" {
  name_prefix          = "wireguard-${var.ts_env}-"
  image_id             = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  key_name             = var.ssh_key_id
  security_groups      = [var.wireguard_sg]
  iam_instance_profile = var.ec2_iam_role
  user_data = templatefile("${path.module}/templates/initialize.sh", {
    wg_server_net                      = var.wg_server_net,
    wg_server_port                     = var.wg_server_port,
    efs_dns_name                       = var.efs_dns,
    allowed_ips                        = var.allowed_ips,
    public_dns                         = var.public_dns,
  })  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "wireguard_asg" {
  name                 = "wireguard_asg"
  launch_configuration = aws_launch_configuration.wireguard_launch_config.name
  min_size             = var.asg_min_size
  desired_capacity     = var.asg_desired_capacity
  max_size             = var.asg_max_size
  vpc_zone_identifier  = var.subnet_ids
  health_check_type    = "EC2"
  termination_policies = ["OldestLaunchConfiguration", "OldestInstance"]
  target_group_arns    = [var.target_group_arn]

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Name"
      value               = aws_launch_configuration.wireguard_launch_config.name
      propagate_at_launch = true
    },
    {
      key                 = "env"
      value               = var.ts_env
      propagate_at_launch = true
    },
    {
      key                 = "tf-managed"
      value               = "True"
      propagate_at_launch = true
    },
  ]
}