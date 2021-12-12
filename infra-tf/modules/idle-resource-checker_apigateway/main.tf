
locals {

  # List of [ { "idle-resource-checker-lambda_eips-get", invoke_arn, "eip-get", "GET" }, { "idle-resource-checker-lambda_eips-scan", invoke_arn, "eip-scan", "GET" }, { "idle-resource-checker-lambda_eips-delete", invoke_arn, "eip-delete", "DELETE" }, { "idle-resource-checker-lambda_elbs-get", invoke_arn, elb-get, "GET" }, { "idle-resource-checker-lambda_elbs-scan", invoke_arn, elb-scan, "GET" }, { "idle-resource-checker-lambda_elbs-delete", invoke_arn, elb-delete, "DELETE" }, etc...
  idle-resource-checker-apigateway_function_all_matrix = [
  for item in var.idle-resource-checker-lambda_functions :
    tomap({
      "function_name" = var.idle-resource-checker-lambda_functions[index(var.idle-resource-checker-lambda_functions, item)].function_name,
      "invoke_arn"    = var.idle-resource-checker-lambda_functions[index(var.idle-resource-checker-lambda_functions, item)].invoke_arn,
      "path_suffix"   = split("_",var.idle-resource-checker-lambda_functions[index(var.idle-resource-checker-lambda_functions, item)].function_name)[1]
      "http_method"   = var.idle-resource-checker-apigateway_methods[index(var.idle-resource-checker-lambda_functions, item) % length(var.idle-resource-checker-apigateway_methods)]
    })
  ]

}

resource "aws_api_gateway_rest_api" "ResourceCleanerRestAPI" {
  name = var.idle-resource-checker-apigateway_api-url-name
}

resource "aws_api_gateway_resource" "APIGatewayPath" {
  parent_id   = aws_api_gateway_rest_api.ResourceCleanerRestAPI.root_resource_id
  path_part   = local.idle-resource-checker-apigateway_function_all_matrix[count.index].path_suffix
  rest_api_id = aws_api_gateway_rest_api.ResourceCleanerRestAPI.id
  count       = length(local.idle-resource-checker-apigateway_function_all_matrix)
}

resource "aws_api_gateway_method" "APIGatewayRestAPIMethod" {
  authorization = "NONE"
  http_method   = local.idle-resource-checker-apigateway_function_all_matrix[count.index].http_method
  rest_api_id   = aws_api_gateway_rest_api.ResourceCleanerRestAPI.id
  resource_id   = aws_api_gateway_resource.APIGatewayPath[count.index].id
  count         = length(local.idle-resource-checker-apigateway_function_all_matrix)
}

resource "aws_api_gateway_integration" "APIGatewayRestAPIIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.ResourceCleanerRestAPI.id
  resource_id             = aws_api_gateway_resource.APIGatewayPath[count.index].id
  http_method             = local.idle-resource-checker-apigateway_function_all_matrix[count.index].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = local.idle-resource-checker-apigateway_function_all_matrix[count.index].invoke_arn
  count                   = length(local.idle-resource-checker-apigateway_function_all_matrix)
  # Should not be needed but it is
  depends_on              = [ aws_api_gateway_method.APIGatewayRestAPIMethod ]
}

resource "aws_lambda_permission" "APIGatewayRestAPIMethodPermission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = element(var.idle-resource-checker-lambda_functions, count.index).function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ResourceCleanerRestAPI.execution_arn}/*/*/*"
  count         = length(var.idle-resource-checker-lambda_functions)
}

resource "aws_api_gateway_deployment" "APIGatewayRestAPIDeployment" {
  rest_api_id = aws_api_gateway_rest_api.ResourceCleanerRestAPI.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_resource.APIGatewayPath,
    aws_api_gateway_integration.APIGatewayRestAPIIntegration
  ]
}

resource "aws_api_gateway_stage" "APIGatewayRestAPIStage" {
  deployment_id = aws_api_gateway_deployment.APIGatewayRestAPIDeployment.id
  rest_api_id   = aws_api_gateway_rest_api.ResourceCleanerRestAPI.id
  stage_name    = var.idle-resource-checker-apigateway_api-url-name
}