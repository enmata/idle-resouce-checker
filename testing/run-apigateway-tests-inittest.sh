#!/bin/bash

cd $TESTING_FOLDER/inittest-validation

# Getting API Gateway URL
export API_GW_ID=$(aws apigateway get-rest-apis | awk -F'"' '/"id"/ {print $4}')
export API_BASE_URL=https://$API_GW_ID.execute-api.$AWS_REGION.amazonaws.com/resource-cleaner
export TESTS_JSON_FILE=eips_tests.json
export TESTS_RESPONSE_SCHEMA_FILE=eips_schema.json

# export TESTS_JSON_FILE=enis_tests.json
# export TESTS_RESPONSE_SCHEMA_FILE=enis_schema.json

# export TESTS_JSON_FILE=elbs_tests.json
# export TESTS_RESPONSE_SCHEMA_FILE=elbs_schema.json

# export TESTS_JSON_FILE=global_tests.json
# export TESTS_RESPONSE_SCHEMA_FILE=global_schema.json

# creating environment and sourcing requirements
echo "[test-apigateway-inittest] Creating environment and sourcing requirements..."
python3 -m virtualenv testing_env -q
. testing_env/bin/activate
pip3 install -q -r run-apigateway-tests-inittest_requirements.txt

# running apigateway unit test use cases
echo "[test-apigateway-inittest] Running apigateway unit test use cases..."
python3 -m pytest -v -rA inittest_validation.py || exit 0

# wrapping up
echo "[test-apigateway-inittest] Wrapping up..."
#deactivate || exit 0
rm -rf testing_env __pycache__/ .pytest_cache/
