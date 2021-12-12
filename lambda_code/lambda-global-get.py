import boto3
from botocore.exceptions import ClientError
import json


def lambda_handler(event, context):
    # Creating DynamoDB client
    dynamodb_client = boto3.resource('dynamodb')
    table = dynamodb_client.Table('resources')

    try:
        # Getting results
        response = table.scan()
        data = response['Items']

    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        return {
            "statusCode": 200,
            "body": json.dumps(data)
        }
