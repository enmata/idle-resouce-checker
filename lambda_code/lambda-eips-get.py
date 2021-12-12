import boto3
from botocore.exceptions import ClientError
from boto3.dynamodb.conditions import Key
import json


def lambda_handler(event, context):
    # Creating DynamoDB client
    dynamodb_client = boto3.resource('dynamodb')
    table = dynamodb_client.Table('resources')

    try:
        # Setting resource types
        entry = ["NETWORK-eip"]

        # Getting results
        result = []
        for filter in entry:
            scan_kwargs = {
                'FilterExpression': Key('type').eq(filter)
            }
            response = table.scan(**scan_kwargs)
            result += response['Items']

    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        return {
            "statusCode": 200,
            "body": json.dumps(result)
        }
