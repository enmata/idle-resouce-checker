#!/bin/bash

# Setting variables
declare -a RESOURCE_NAME=(eips elbs enis global)
declare -a ACTION_NAME=(get scan delete)

# Uploading lambda code
echo "[deploy-tf] Uploading lambda code..."
for RESOURCE in "${RESOURCE_NAME[@]}"
do
  for ACTION in "${ACTION_NAME[@]}"
  do
      echo "[deploy-tf] Updating idle-resource-checker-lambda_$RESOURCE-$ACTION code..."
      aws lambda update-function-code --function-name "idle-resource-checker-lambda_$RESOURCE-$ACTION" --zip-file fileb://$LAMBDA_CODE_FOLDER/lambda-$RESOURCE-$ACTION.zip  > /dev/null
  done
done
