#!/bin/bash

# Setting variables
declare -a RESOURCE_NAME=(eips elbs enis global)
declare -a ACTION_NAME=(get scan delete)

cd $TERRRAFORM_FOLDER

# DELETING TERRAFORM RESOURCES
echo "[clean-tf] Deleting Terraform resources stack..."
terraform destroy -auto-approve > /dev/null
rm -rf terraform.tfstate* .terraform*

# DELETING LAMBDA BUNDLES
echo "[clean-cf] Deleting lambda bundles..."
cd ..
for RESOURCE in "${RESOURCE_NAME[@]}"
do
  for ACTION in "${ACTION_NAME[@]}"
  do
    rm -f $LAMBDA_CODE_FOLDER/lambda-$RESOURCE-$ACTION.zip
  done
done
