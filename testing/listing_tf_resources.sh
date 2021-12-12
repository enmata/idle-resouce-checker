#!/bin/bash

cd $TERRRAFORM_FOLDER

# LISTING TERRAFORM MANIFEST RESOURCES
echo "\n[test-cf-listing] Terraform manifest resources...\n"
terraform state list

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

cd ..
