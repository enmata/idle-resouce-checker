#!/bin/bash

# Setting variables
declare -a RESOURCE_NAME=(eips elbs enis global)
declare -a ACTION_NAME=(get scan delete)
export BUCKET_NAME="bucket-upload-$(openssl rand -hex 8)"

# CREATING S3 BUCKET
echo "[deploy-tf] Creating s3 bucket $BUCKET_NAME..."
aws s3api create-bucket --bucket $BUCKET_NAME --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION

# UPLOADING LAMBDA CODE TO S3 BUCKET
echo "[deploy-tf] Uploading lambda code to s3 bucket..."
#aws s3 cp lambda/ s3://$BUCKET_NAME --recursive --exclude "*" --include "*.zip"
for RESOURCE in "${RESOURCE_NAME[@]}"
do
  for ACTION in "${ACTION_NAME[@]}"
  do
      aws s3 cp $LAMBDA_CODE_FOLDER/lambda-$RESOURCE-$ACTION.zip s3://$BUCKET_NAME
  done
done

# Deploying CloudFormation resources
echo "[deploy-tf] Deploying $STACK_NAME stack..."
aws cloudformation deploy --stack-name $STACK_NAME --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --template-file $CLOUDFORMATION_FOLDER/CloudFormation.yaml

# Waiting until CloudFormation stack completion
aws cloudformation wait stack-create-complete --stack-name $STACK_NAME

# # DELETING CLOUDFORMATION
# echo "[clean-cf] Deleting $STACK_NAME CloudFormation stack..."
# aws cloudformation delete-stack --stack-name $STACK_NAME

# Deleting uploaded code
for RESOURCE in "${RESOURCE_NAME[@]}"
do
  for ACTION in "${ACTION_NAME[@]}"
  do
      aws s3 rm s3://$BUCKET_NAME/lambda-$RESOURCE-$ACTION.zip
  done
done

# DELETING BUCKET
echo "[deploy-tf] Deleting s3 bucket $BUCKET_NAME..."
aws s3api delete-bucket --bucket $BUCKET_NAME
