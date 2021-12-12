
output "idle-resource-checker-lambda_functions_arn" {
  description = "The arn of the created lambda functions"
  value = module.idle-resource-checker_lambda.idle-resource-checker-lambda_functions_arn
}

output "idle-resource-checker-dynamodb_table" {
  description = "DynamoDB table created"
  value = module.idle-resource-checker_dynamodb.idle-resource-checker-dynamodb_table
}

output "idle-resource-checker-apigateway_rootURL" {
  description = "Root API Gateway URL"
  value = module.idle-resource-checker_apigateway.idle-resource-checker-apigateway_rootURL
}

output "idle-resource-checker-apigateway_APIURLs" {
  description = "ALL API Gateway URLs"
  value = module.idle-resource-checker_apigateway.idle-resource-checker-apigateway_APIURLs
}