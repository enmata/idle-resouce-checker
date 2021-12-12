import boto3
from botocore.exceptions import ClientError
import json


def lambda_handler(event, context):
    # Creating DynamoDB client
    dynamodb_client = boto3.client('dynamodb')

    try:
        # Deleting table
        dynamodb_client.delete_table(TableName='resources')

        # Waiting delete completion
        waiter = dynamodb_client.get_waiter('table_not_exists')
        waiter.wait(TableName='resources')

        # Creating table
        dynamodb_client.create_table(
            AttributeDefinitions=[
                {
                    'AttributeName': 'arn',
                    'AttributeType': 'S'
                },
                {
                    'AttributeName': 'type',
                    'AttributeType': 'S'
                }
            ],
            TableName='resources',
            KeySchema=[
                {
                    'AttributeName': 'arn',
                    'KeyType': 'HASH'
                },
                {
                    'AttributeName': 'type',
                    'KeyType': 'RANGE'
                }
            ],
            ProvisionedThroughput={
                'ReadCapacityUnits': 1,
                'WriteCapacityUnits': 1
            })

    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        return {
            "statusCode": 200,
            "body": json.dumps('DynamoDB Table recreated')
        }
