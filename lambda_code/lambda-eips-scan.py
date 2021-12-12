from datetime import datetime
from botocore.exceptions import ClientError
import boto3
import json


def lambda_handler(event, context):
    # Creating EIP boto3 client
    ec2_client = boto3.client('ec2')
    # Creating DynamoDB client
    dynamodb_client = boto3.resource('dynamodb')
    table = dynamodb_client.Table('resources')

    try:
        # Getting all addresses from AWS API
        eips = ec2_client.describe_addresses(Filters=[{'Name': 'domain', 'Values': ['vpc']}])

        # Checking idle/attached addresses
        for eip in eips["Addresses"]:
            if "PrivateIpAddress" not in eip or "AssociationId" not in eip:
                # public idle IP, NOT assigned
                # Inserting on DynamoDB table
                response = table.put_item(
                    Item={
                        'arn': eip["AllocationId"],
                        'type': 'NETWORK-eip',
                        'public_ip': eip["PublicIp"],
                        'available_from': str(datetime.now()),
                        'region': context.invoked_function_arn.split(':')[3],
                        'account': context.invoked_function_arn.split(':')[4]
                    }
                )

    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        return {
            "statusCode": 200,
            "body": json.dumps('EIPs scanned')
        }
