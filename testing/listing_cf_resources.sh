#!/bin/bash

# LISTING CLOUDFORMATION STACK RESOURCES
echo "\n[test-cf-listing] Listing CloudFormation Stack resources...\n"
aws cloudformation describe-stacks --stack-name $STACK_NAME

# LISTING LAMBDA FUNCTIONS
echo "\n[test-cf-listing] Listing Lambda functions...\n"
aws lambda list-functions

# LISTING API GATEWAY
echo "\n[test-cf-listing] Listing API Gateway resources...\n"
export API_GW_ID=$(aws apigateway get-rest-apis | awk -F'"' '/"id"/ {print $4}')
aws apigateway get-rest-apis
aws apigateway get-resources --rest-api-id $API_GW_ID

# LISTING DYNAMODB
echo "\n[test-cf-listing] Listing DynamoDB resources...\n"
aws dynamodb list-tables
aws dynamodb scan --table-name resources
