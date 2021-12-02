module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "wireguard_abm"
  description   = "Sends create, delete and refresh to wireguard nodes using SSM"
  handler       = "wireguard_lambda_abm.lambda_handler"
  runtime       = "python3.8"
  create_role   = false 
  lambda_role   = "arn:aws:iam::277148483112:role/LambdaWireguardVPN"

  timeout       = 180
  source_path = "${path.module}/script/wireguard_lambda_abm.py"

  environment_variables = {
    slack_token = var.slack_token,
  }
}
