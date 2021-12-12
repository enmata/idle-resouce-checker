
module "idle-resource-checker_lambda" {
  source = "./modules/idle-resource-checker_lambda"

  idle-resource-checker-lambda_actions = var.idle-resource-checker-root_actions
  idle-resource-checker-lambda_resources = var.idle-resource-checker-root_resources
}

module "idle-resource-checker_dynamodb" {
  source = "./modules/idle-resource-checker_dynamodb"

  # Input implies and implicit dependency of idle-resource-checker_lambda module
  idle-resource-checker-lambda_roles          = module.idle-resource-checker_lambda.idle-resource-checker-lambda_roles
}

module "idle-resource-checker_apigateway" {
  source = "./modules/idle-resource-checker_apigateway"

  # Input implies and implicit dependency of idle-resource-checker_lambda module
  idle-resource-checker-lambda_functions        = module.idle-resource-checker_lambda.idle-resource-checker-lambda_functions
  idle-resource-checker-apigateway_resources    = var.idle-resource-checker-root_resources
  idle-resource-checker-apigateway_api-url-name = var.idle-resource-checker-apigateway_api-url-name
}
