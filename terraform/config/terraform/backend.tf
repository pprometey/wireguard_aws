# TS_ENV values: dev, prod
terraform {
  backend "s3" {
    bucket         = "terraform-states-trafnetwork"
    key            = "<%= expansion(':REGION/vpn/:MOD_NAME.tfstate') %>"
    dynamodb_table = "terraform-locks-trafnetwork"
    region         = "<%= expansion(':REGION') %>"
    encrypt        = true
  }
}