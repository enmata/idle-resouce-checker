#!/bin/bash

# Getting API Gateway URL
export AWS_REGION=eu-west-1
export API_GW_ID=$(aws apigateway get-rest-apis | awk -F'"' '/"id"/ {print $4}')
export API_BASE_URL=https://$API_GW_ID.execute-api.$AWS_REGION.amazonaws.com/resource-cleaner

# EIPs
# RUNNING EIPS SCAN LAMBDA
echo "[test-apigateway-curl] Running eips scan lambda...\n"
curl $API_BASE_URL/eips-scan
# GETTING EIP ENTRIES
echo "\n\n[test-apigateway-curl] Getting eips entries...\n"
curl $API_BASE_URL/eips-get
# Deleting one specific entry (from AWS account and also from DynamoDB)
# echo "\n\n[test-scan] Deleting one specific entry...\n"
# curl -X DELETE $API_BASE_URL/eips-delete -H "Content-Type: application/json" -d '{"arn":"eipalloc-0034dfc6e8e8b53d7","type":"NETWORK-eip"}'
# curl -X DELETE $API_BASE_URL/eips-delete -H "Content-Type: application/json" -d '{"arn":"eipalloc-0972eea87268a9de1","type":"NETWORK-eip"}'

# ELBs
# RUNNING ELBS SCAN LAMBDA
echo "\n\n[test-apigateway-curl] Running elbs scan lambda...\n"
curl $API_BASE_URL/elbs-scan
# GETTING ELB ENTRIES
echo "\n\n[test-apigateway-curl] Getting elb entries...\n"
curl $API_BASE_URL/elbs-get
# Deleting one specific entry (from AWS account and also from DynamoDB)
# echo "\n\n[test-scan] Deleting one specific entry...\n"
# curl -X DELETE $API_BASE_URL/elbs-delete -H "Content-Type: application/json" -d '{"arn":"arn:aws:elasticloadbalancing:eu-west-1:000000000000:loadbalancer/ELBClassic-ToDelete", "lb_name":"ELBClassic-ToDelete", "type":"NETWORK-ELB-ClassicLB"}'

# ENIs
# RUNNING ENIS SCAN LAMBDA
echo "\n\n[test-apigateway-curl] Running enis scan lambda...\n"
curl $API_BASE_URL/enis-scan
# GETTING ENIS ENTRIES
echo "\n\n[test-apigateway-curl] Getting enis entries...\n"
curl $API_BASE_URL/enis-get
# DELETING ONE SPECIFIC ENTRY (FROM AWS ACCOUNT AND ALSO FROM DYNAMODB)
# echo "\n\n[test-scan] Deleting one specific entry...\n"
# curl -X DELETE $API_BASE_URL/enis-delete -H "Content-Type: application/json" -d '{"arn":"eni-0fb90de7ccf996a3d","type":"NETWORK-ENI-EC2Private"}'
# curl -X DELETE $API_BASE_URL/enis-delete -H "Content-Type: application/json" -d '{"arn":"eni-0d27326165d506510","type":"NETWORK-ENI-EC2Private"}'


# All DynamoDB entries
# DUMPING ALL DYNAMODB CONTENTS
echo "\n\n[test-apigateway-curl] Dumping all DynamoDB contents...\n"
curl -X GET $API_BASE_URL/global-get
# RESETTING (DELETE + CREATE) DYNAMODB TABLE, NOTHING ON AWS ACCOUNTS
echo "\n\n[test-apigateway-curl] Resetting (delete + create) DynamoDB table...\n"
curl -X DELETE $API_BASE_URL/global-delete
# RUNNING SCAN FOR ENIS ELBS EIPS RESOURCES
echo "\n\n[test-apigateway-curl] Running scan for enis elbs eips resources...\n"
curl -X GET $API_BASE_URL/global-scan
# DUMPING ALL DYNAMODB CONTENTS
echo "\n\n[test-apigateway-curl] Dumping all DynamoDB contents...\n"
curl -X GET $API_BASE_URL/global-get
