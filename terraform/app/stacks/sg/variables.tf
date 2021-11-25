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

variable "wg_server_port" {
  description = "Wireguard Server Port"
  default     = 51820
  type        = number
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-0168c2f02fd3d2027"
}