
variable "idle-resource-checker-lambda_functions" {
  type = list(object({
    function_name = string
    invoke_arn = string
  }))
}

variable "idle-resource-checker-apigateway_resources" {
  type = list(string)
  default = ["eips", "elbs", "enis", "global"]
}

variable "idle-resource-checker-apigateway_actions" {
  type = list(string)
  default = ["get", "scan", "delete"]
}

variable "idle-resource-checker-apigateway_methods" {
  type = list(string)
  default = ["DELETE", "GET", "GET"]
}

variable "idle-resource-checker-apigateway_api-url-name" {
  type = string
  default = "resource-cleaner"
}