import boto3
import json
import requests

def lambda_handler(event, context):

    print(event['headers']['Host'])
    API_GATEWAY_EIPS_SCAN_URL="https://" + event['headers']['Host'] + "/resource-cleaner/eips-scan"
    requests.get(url=API_GATEWAY_EIPS_SCAN_URL, verify=False)
    API_GATEWAY_ENIS_SCAN_URL="https://" + event['headers']['Host'] + "/resource-cleaner/enis-scan"
    requests.get(url=API_GATEWAY_ENIS_SCAN_URL, verify=False)
    API_GATEWAY_ELBS_SCAN_URL="https://" + event['headers']['Host'] + "/resource-cleaner/elbs-scan"
    requests.get(url=API_GATEWAY_ELBS_SCAN_URL, verify=False)

    return {
        "statusCode": 200,
        "body": json.dumps('EIPS, ENIs and ELBs scanned'))
    }
