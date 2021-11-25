# This is where you put your variables declaration
variable "ts_env" {
  description = "Current Environment - Short name"
  type        = string
  default     = "<%= expansion(':ENV') %>"
}

variable "ts_region" {
  description = "Current Region - Short name"
  type        = string
  default     = "<%= expansion(':REGION') %>"
}

variable "wireguard_sg" {
    description = "Wireguard Security Group"
}

variable "efs_dns" {}

variable "instance_type" {
  default     = "t2.micro"
  description = "The machine type to launch, some machines may offer higher throughput for higher use cases."
}

variable "ssh_key_id" {
  description = "A SSH public key ID to add to the VPN instance."
  default = "trafilea-network"
}

variable "wg_server_port" {
  description = "Wireguard Server Port"
  default     = 51820
  type        = number
}

variable "wg_server_net" {
  description = "Wireguard Server Network CIDR"
  type = string
  default = "10.50.0.1"
}

variable "asg_min_size" {
  default     = 1
}

variable "asg_desired_capacity" {
  default     = 1
}

variable "asg_max_size" {
  default     = 3
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnets for the Autoscaling Group to use for launching instances. May be a single subnet, but it must be an element in a list."
  default = [ "subnet-033b4362bb5aeef3f", "subnet-087f86b851460da79", "subnet-0fb92c6d930240664" ]
}

variable "target_group_arns" {
  type        = list(string)
  default     = null
  description = "Running a scaling group behind an LB requires this variable, default null means it won't be included if not set."
}

variable "allowed_ips" {
  type = string
  description = "CIDR blocks of main VPC + peering to other accounts"
  default = "172.31.0.0/16,172.22.0.0/16"
}

variable "ec2_iam_role" {
  description = "EC2 IAM role"
  type = string
  default = "EC2Role_VPN"
}


variable "lb_arn" {
  description = "ARN of the network load balancer"
}

variable "lb_id" {
  description = "ID of the network load balancer"
}

variable "public_dns" {
}