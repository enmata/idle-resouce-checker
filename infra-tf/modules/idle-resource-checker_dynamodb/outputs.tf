
output "idle-resource-checker-dynamodb_table" {
  description = "DynamoDB table created"
  value = aws_dynamodb_table.dynamodb-table.name
}
