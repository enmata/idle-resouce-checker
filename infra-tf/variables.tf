
variable "idle-resource-checker-root_actions" {
  type    = list(string)
  default = ["get", "scan", "delete"]
}

variable "idle-resource-checker-root_resources" {
  type = list(string)
  default = ["eips", "elbs", "enis", "global"]
}

variable "idle-resource-checker-apigateway_api-url-name" {
  type = string
  default = "resource-cleaner"
}