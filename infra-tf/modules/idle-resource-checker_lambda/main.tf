
locals {

  idle-resource-checker-policy_matrix-get_r = distinct(flatten([
    for resource_name in var.idle-resource-checker-lambda_resources : [
      tomap({
        "policy_name"     = "idle-resource-checker-lambda-policy_${resource_name}-read",
        "policy_filename" = "${path.module}/../../../policies/policy-${resource_name}-r.json",
        "role_name"       = "idle-resource-checker-lambda-role_${resource_name}-get"
      })
    ]
  ]))

  idle-resource-checker-policy_matrix-scan_r = distinct(flatten([
    for resource_name in var.idle-resource-checker-lambda_resources : [
      tomap({
        "policy_name"     = "idle-resource-checker-lambda-policy_${resource_name}-read",
        "policy_filename" = "${path.module}/../../../policies/policy-${resource_name}-r.json",
        "role_name"       = "idle-resource-checker-lambda-role_${resource_name}-scan"
      })
    ]
  ]))

  idle-resource-checker-policy_matrix-scan_w = distinct(flatten([
    for resource_name in var.idle-resource-checker-lambda_resources : [
      tomap({
        "policy_name"     = "idle-resource-checker-lambda-policy_${resource_name}-write",
        "policy_filename" = "${path.module}/../../../policies/policy-${resource_name}-w.json",
        "role_name"       = "idle-resource-checker-lambda-role_${resource_name}-scan"
      })
    ]
  ]))

  idle-resource-checker-policy_matrix-delete_r = distinct(flatten([
    for resource_name in var.idle-resource-checker-lambda_resources : [
      tomap({
        "policy_name"     = "idle-resource-checker-lambda-policy_${resource_name}-read",
        "policy_filename" = "${path.module}/../../../policies/policy-${resource_name}-r.json",
        "role_name"       = "idle-resource-checker-lambda-role_${resource_name}-delete"
      })
    ]
  ]))

  idle-resource-checker-policy_matrix-delete_w = distinct(flatten([
  for resource_name in var.idle-resource-checker-lambda_resources : [
    tomap({
      "policy_name"     = "idle-resource-checker-lambda-policy_${resource_name}-write",
      "policy_filename" = "${path.module}/../../../policies/policy-${resource_name}-w.json",
      "role_name"       = "idle-resource-checker-lambda-role_${resource_name}-delete"
    })
  ]
  ]))

  idle-resource-checker-policy_matrix = concat(local.idle-resource-checker-policy_matrix-get_r,local.idle-resource-checker-policy_matrix-scan_r,local.idle-resource-checker-policy_matrix-scan_w,local.idle-resource-checker-policy_matrix-delete_r,local.idle-resource-checker-policy_matrix-delete_w)

  idle-resource-checker-lambda_roles_name_list = distinct(flatten([
    for resource_name in var.idle-resource-checker-lambda_resources : [
      for action in var.idle-resource-checker-lambda_actions : {
        "role_name"       = "idle-resource-checker-lambda-role_${resource_name}-${action}"
      }
    ]
  ]))

  # Need to generate role_arn
  account_id = data.aws_caller_identity.current.account_id

  idle-resource-checker-lambda_function_name_matrix = distinct(flatten([
  for resource_name in var.idle-resource-checker-lambda_resources : [
    for action in var.idle-resource-checker-lambda_actions : {
      "function_name" = "idle-resource-checker-lambda_${resource_name}-${action}",
      "filename"      = "${path.module}/../../../lambda_code/lambda-${resource_name}-${action}.zip",
      "handler"       = "lambda-${resource_name}-${action}.lambda_handler",
      "role_name"     = "idle-resource-checker-lambda-role_${resource_name}-${action}",
      # Not using native "aws_iam_role.Custom-RoleLambda[*].arn" due index dynamic resources lookup raise conditions
      "role_arn"      = "arn:aws:iam::${local.account_id}:role/idle-resource-checker-lambda-role_${resource_name}-${action}"
    }
  ]
  ]))

}

resource "aws_iam_role_policy" "Custom-PolicyLambda" {
  name      = local.idle-resource-checker-policy_matrix[count.index].policy_name
  role      = local.idle-resource-checker-policy_matrix[count.index].role_name
  policy    = file(local.idle-resource-checker-policy_matrix[count.index].policy_filename)
  count     = length(local.idle-resource-checker-policy_matrix)
  # Needed due role_arn is generated dynamically, and no implicid dependency is generated
  depends_on = [ aws_iam_role.Custom-RoleLambda ]
}

resource "aws_iam_role" "Custom-RoleLambda" {
  name               = local.idle-resource-checker-lambda_roles_name_list[count.index].role_name
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  inline_policy {
    name   = "idle-resource-checker-lambda-policy_loggingGroups"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:logs:*:*:*"
        },
      ]
    })
  }
  count = length(local.idle-resource-checker-lambda_roles_name_list)
  tags = {
    ecs-updater-terraform = "idle-resource-checker-lambda"
  }
}

resource "aws_lambda_function" "Lambda" {
  function_name = local.idle-resource-checker-lambda_function_name_matrix[count.index].function_name
  filename      = local.idle-resource-checker-lambda_function_name_matrix[count.index].filename
  role          = local.idle-resource-checker-lambda_function_name_matrix[count.index].role_arn
  handler       = local.idle-resource-checker-lambda_function_name_matrix[count.index].handler
  runtime       = "python3.9"
  reserved_concurrent_executions = 1
  timeout       = 30
  count         = length(local.idle-resource-checker-lambda_function_name_matrix)
  # Needed due role_arn is generated dynamically, and no implicid dependency is generated
  depends_on = [
    aws_iam_role.Custom-RoleLambda
  ]
  tags = {
    ecs-updater-terraform = "idle-resource-checker-lambda"
  }
}
