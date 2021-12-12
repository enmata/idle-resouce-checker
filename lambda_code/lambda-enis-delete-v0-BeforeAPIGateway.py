import boto3


def lambda_handler(event, context):

    # Creating ENI boto3 client
    ec2_client = boto3.client('ec2')
    # Deleting/releasing the ENI (AWS account)
    response = ec2_client.delete_network_interface(NetworkInterfaceId=event['arn'])

    # Creating DynamoDB client
    dynamodb_client = boto3.resource('dynamodb')
    table = dynamodb_client.Table('resources')
    # Deleting/releasing the ENI (DynamoDB)
    table.delete_item(
        Key={
            'arn': event['arn'],
            'type': event['type'],
        }
    )

    return {
        'statusCode': response['ResponseMetadata']['HTTPStatusCode'],
        'body': 'EIP Record deleted'
    }
