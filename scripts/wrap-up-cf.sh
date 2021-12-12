#!/bin/bash

# Setting variables
declare -a RESOURCE_NAME=(eips elbs enis global)
declare -a ACTION_NAME=(get scan delete)

# DELETING CLOUDFORMATION RESOURCES
echo "[clean-cf] Deleting $STACK_NAME CloudFormation stack..."
aws cloudformation delete-stack --stack-name $STACK_NAME
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME

# DELETING LAMBDA BUNDLES
echo "[clean-cf] Deleting lambda bundles..."
for RESOURCE in "${RESOURCE_NAME[@]}"
do
  for ACTION in "${ACTION_NAME[@]}"
  do
      rm -f $LAMBDA_CODE_FOLDER/lambda-$RESOURCE-$ACTION.zip
  done
done
