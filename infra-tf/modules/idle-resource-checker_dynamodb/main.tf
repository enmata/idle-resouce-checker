
locals {
  idle-resource-checker-dynamodb_roles_RW = [for role in var.idle-resource-checker-lambda_roles : role if length(regexall(".*get", role.role_name)) == 0]
}

resource "aws_dynamodb_table" "dynamodb-table" {
  name           = var.idle-resource-checker-dynamodb_tablename
  read_capacity  = 1
  write_capacity = 1
  hash_key       = var.idle-resource-checker-dynamodb_hash_key
  range_key      = var.idle-resource-checker-dynamodb_range_key
  attribute {
    name = var.idle-resource-checker-dynamodb_hash_key
    type = "S"
  }

  attribute {
    name = var.idle-resource-checker-dynamodb_range_key
    type = "S"
  }
}

resource "aws_iam_role_policy" "Custom-PolicyDynamoRO" {
  name          = "idle-resource-checker-dynamodb-policy_read"
  role          = var.idle-resource-checker-lambda_roles[count.index].role_id
  policy        = file("${path.module}/../../../policies/policy-dynamodb-ro.json")
  count         = length(var.idle-resource-checker-lambda_roles)
}

resource "aws_iam_role_policy" "Custom-PolicyDynamoRW" {
  name          = "idle-resource-checker-dynamodb-policy_readwrite"
  role          = local.idle-resource-checker-dynamodb_roles_RW[count.index].role_id
  policy        = file("${path.module}/../../../policies/policy-dynamodb-rw.json")
  count         = length(local.idle-resource-checker-dynamodb_roles_RW)
}

resource "aws_iam_role_policy" "Custom-PolicyDynamoRWCD" {
  name          = "idle-resource-checker-dynamodb-policy_readwritecreateDelete"
  role          = var.idle-resource-checker-lambda_roles[index(var.idle-resource-checker-lambda_roles.*.role_name,"idle-resource-checker-lambda-role_global-delete")].role_id
  policy        = file("${path.module}/../../../policies/policy-dynamodb-rwcd.json")
}