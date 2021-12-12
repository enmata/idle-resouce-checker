
variable "idle-resource-checker-dynamodb_tablename" {
  type = string
  default = "resources"
}

variable "idle-resource-checker-dynamodb_hash_key" {
  type = string
  default = "arn"
}

variable "idle-resource-checker-dynamodb_range_key" {
  type = string
  default = "type"
}

variable "idle-resource-checker-lambda_roles" {
  type = list(object({
    role_name = string
    role_id = string
  }))
}
