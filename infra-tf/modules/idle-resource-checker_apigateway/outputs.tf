
output "idle-resource-checker-apigateway_rootURL" {
  description = "Root API Gateway URL"
  value = "${aws_api_gateway_deployment.APIGatewayRestAPIDeployment.invoke_url}${var.idle-resource-checker-apigateway_api-url-name}"
}

output "idle-resource-checker-apigateway_APIURLs" {
  description = "The URLs for the different API endpoints"
  value = {
    for url, path in aws_api_gateway_resource.APIGatewayPath:
      url => "${aws_api_gateway_deployment.APIGatewayRestAPIDeployment.invoke_url}${var.idle-resource-checker-apigateway_api-url-name}/${path.path_part}"
  }
}