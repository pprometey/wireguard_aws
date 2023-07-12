# Docs: https://www.terraform.io/docs/providers/aws/index.html
#
# If AWS_PROFILE and AWS_REGION is set, then the provider is optional.  Here's an example anyway:
#
# provider "aws" {
#   region = "us-east-1"
# }

provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      Application = "vpn"
      Environment = "<%= expansion(':ENV') %>"
      Owner       = "infrastructure"
      Provisioned = "Terraspace"
    }
  }
}
