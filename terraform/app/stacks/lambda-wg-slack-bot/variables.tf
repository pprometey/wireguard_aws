# Not really secure but i dont think its much of compromise tbh
variable "slack_token" {
  description = "Slack API token"
  type        = string
  default = "xoxb-3879704428-2778276589011-jewfDNRRhNA1nhGBVDNVoOwT"
}

variable "slack_secret" {
  description = "Slack API secret for verifying messages"
  type        = string
  default     = "748d1112b8cb70754b79ddbc73ca1a64"
}