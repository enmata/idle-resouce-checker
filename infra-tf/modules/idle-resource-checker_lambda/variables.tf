
variable "idle-resource-checker-lambda_actions" {
  type    = list(string)
  default = ["get", "scan", "delete"]
}

variable "idle-resource-checker-lambda_resources" {
  type = list(string)
  default = ["eips", "elbs", "enis", "global"]
}