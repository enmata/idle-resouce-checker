import boto3
from boto3.dynamodb.conditions import Key
import json

def lambda_handler(event, context):

    # Creating DynamoDB client
    dynamodb_client = boto3.resource('dynamodb')
    table = dynamodb_client.Table('resources')

    try:
        # Getting parameters
        entry=json.loads(event['body'])

        # Getting results
        result = []
        for filter in entry['type']:
            scan_kwargs = {
                'FilterExpression': Key('type').eq(filter)
            }
            response = table.scan(**scan_kwargs)
            result += response['Items']

        return result