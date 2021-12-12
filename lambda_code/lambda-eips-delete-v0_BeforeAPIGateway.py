import boto3


def lambda_handler(event, context):

    # Creating EIP boto3 client
    ec2_client = boto3.client('ec2')

    # Creating DynamoDB client
    dynamodb_client = boto3.resource('dynamodb')
    table = dynamodb_client.Table('resources')

    # Deleting/releasing the EIP (AWS account)
    response = ec2_client.release_address(AllocationId=event['arn'])

    # Deleting/releasing the EIP (DynamoDB)
    response = table.delete_item(
        Key={
            'arn': event['arn'],
            'type': event['type'],
        }
    )

    return {
        'statusCode': response['ResponseMetadata']['HTTPStatusCode'],
        'body': 'Entry deleted'
    }
