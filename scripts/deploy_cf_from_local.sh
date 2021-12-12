#!/bin/bash


# VALIDATING CLOUDFORMATION YAML SYNTAX
echo "[deploy-tf] Validating CloudFormation yaml syntax..."
aws cloudformation validate-template --template-body file://$CLOUDFORMATION_FOLDER/CloudFormation.yaml > /dev/null
# Disabled due not present by default in aws cli
# cfn-lint -t file://$CLOUDFORMATION_FOLDER/CloudFormation.yaml

# Deploying CloudFormation resources
echo "[deploy-tf] Deploying $STACK_NAME stack..."
aws cloudformation deploy --stack-name $STACK_NAME --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --template-file $CLOUDFORMATION_FOLDER/CloudFormation.yaml

# Getting Stack ARN
export STACK_ARN=$(aws cloudformation describe-stacks --stack-name $STACK_NAME | awk -F'"' '/"StackId"/ {print $4}')

# Waiting until CloudFormation stack completion
aws cloudformation wait stack-create-complete --stack-name $STACK_ARN
