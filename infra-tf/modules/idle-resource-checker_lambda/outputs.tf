
output "idle-resource-checker-lambda_functions" {
  description = "The invoke_arn of the created lambda functions"
  value = [
    for name, invoke_arn in zipmap(
      aws_lambda_function.Lambda[*].function_name,
      aws_lambda_function.Lambda[*].invoke_arn) :
      tomap({"function_name" = name, "invoke_arn" = invoke_arn})
  ]
}

output "idle-resource-checker-lambda_roles" {
  description = "The ids of the created lambda function roles"
  value = [
    for name, id in zipmap(
      aws_iam_role.Custom-RoleLambda[*].name,
      aws_iam_role.Custom-RoleLambda[*].id) :
        tomap({"role_name" = name, "role_id" = id})
  ]
}

output "idle-resource-checker-lambda_functions_arn" {
  description = "The arn of the created lambda functions"
  value = [
  for name, regular_arn in zipmap(
    aws_lambda_function.Lambda[*].function_name,
    aws_lambda_function.Lambda[*].arn) :
    tomap({"function_name" = name, "arn" = regular_arn})
  ]
}