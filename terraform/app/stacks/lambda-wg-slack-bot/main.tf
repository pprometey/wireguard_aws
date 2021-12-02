module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "wireguard_slack"
  description   = "Proccess incoming slack commands getting users from S3 or passing down requests to wireguard_abm"
  handler       = "wireguard_lambda_bot.lambda_handler"
  runtime       = "python3.8"
  publish       = true
  create_role   = false
  lambda_role   = "arn:aws:iam::277148483112:role/LambdaWireguardVPN"

  timeout     = 180
  source_path = "${path.module}/script/wireguard_lambda_bot.py"

  environment_variables = {
    slack_token  = var.slack_token,
    slack_secret = var.slack_secret,
  }

  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "arn:aws:execute-api:us-east-1:277148483112:up7cxw7c5c/*/*/wireguard_slack"
    }
  }
}
