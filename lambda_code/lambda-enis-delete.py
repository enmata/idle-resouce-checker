import boto3
from botocore.exceptions import ClientError
import json


def lambda_handler(event, context):

    # Creating ENI boto3 client
    ec2_client = boto3.client('ec2')

    # Creating DynamoDB client
    dynamodb_client = boto3.resource('dynamodb')
    table = dynamodb_client.Table('resources')

    try:
        # Getting parameters
        entry=json.loads(event['body'])

        # Deleting/releasing the ENI (AWS account)
        ec2_client.delete_network_interface(NetworkInterfaceId=entry['arn'])

        # Deleting/releasing the ENI (DynamoDB)
        table.delete_item(
            Key={
                'arn': entry['arn'],
                'type': entry['type'],
            }
        )

    except ClientError as e:
        print(e.response['Error']['Message'])

    else:
        return {
            "statusCode": 200,
            "body": json.dumps('ENI Record deleted')
        }

