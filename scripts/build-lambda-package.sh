#!/bin/bash

cd $LAMBDA_CODE_FOLDER

# BUILDING ENI LAMBDA FUNCTIONS...
echo "[build-lambda-package] Building eni lambda functions..."
zip -q lambda-eips-get.zip lambda-eips-get.py
zip -q lambda-eips-scan.zip lambda-eips-scan.py
zip -q lambda-eips-delete.zip lambda-eips-delete.py

# BUILDING ELBS LAMBDA FUNCTIONS...
echo "[build-lambda-package] Building elbs lambda functions..."
zip -q lambda-elbs-get.zip lambda-elbs-get.py
zip -q lambda-elbs-scan.zip lambda-elbs-scan.py lambda_model_elb.py
zip -q lambda-elbs-delete.zip lambda-elbs-delete.py

# BUILDING ENIS LAMBDA FUNCTIONS...
echo "[build-lambda-package] Building enis lambda functions..."
zip -q lambda-enis-get.zip lambda-enis-get.py
zip -q lambda-enis-scan.zip lambda-enis-scan.py lambda_model_eni.py
zip -q lambda-enis-delete.zip lambda-enis-delete.py

# BUILDING GLOBAL LAMBDA FUNCTIONS...
echo "[build-lambda-package] Building global lambda functions..."
zip -q lambda-global-get.zip lambda-global-get.py
zip -q lambda-global-delete.zip lambda-global-delete.py

# Amazon doc reference
# https://docs.aws.amazon.com/lambda/latest/dg/python-package.html#python-package-create-package-with-dependency

# CREATING TEMPORAL FOLDER
echo "[build-lambda-package] Building global lambda functions - Creating temporal folder..."
mkdir -p bundle_tmp

# COPYING COMPONENTS
cp lambda-global-scan.py bundle_tmp/

# DOWNLOADING DEPENDENCIES
echo "[build-lambda-package] Building global lambda functions - Downloading dependencies..."
cd bundle_tmp
pip3 install --quiet --target ./package requests > /dev/null 2>&1
cd package/

echo "[build-lambda-package] Building global lambda functions - Compressing dependencies and components into a bundle..."
# COMPRESSING DEPENDENCIES AND COMPONENTS INTO A BUNDLE
zip -q -r ../lambda-global-scan.zip .
cd ..
zip -q -g lambda-global-scan.zip lambda-global-scan.py

# WRAPPING UP
cp lambda-global-scan.zip ../
cd ..
rm -rf bundle_tmp
