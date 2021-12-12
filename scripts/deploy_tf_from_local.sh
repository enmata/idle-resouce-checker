#!/bin/bash

cd $TERRRAFORM_FOLDER

# INITIALIZING TERRAFORM ENVIRONMENT
terraform init > /dev/null

# VALIDATING TERRAFORM CONFIGURATION SYNTAX
echo "[deploy-tf] Validating configuration syntax..."
terraform validate

# CREATING TERRAFORM RESOURCES
echo "[deploy-tf] Creating Terraform resources..."
terraform apply -input=false -auto-approve  > /dev/null

cd ..
