import boto3
from botocore.exceptions import ClientError
import json


def lambda_handler(event, context):

    try:
        # Getting parameters
        entry=json.loads(event['body'])

        if entry['type'] == "NETWORK-ELB-ClassicLB":
            # Creating Classic ELB boto3 client
            elb_client_v1_release = boto3.client('elb')
            # Deleting/releasing the elb (AWS account)
            response = elb_client_v1_release.delete_load_balancer(LoadBalancerName=entry['lb_name'])

        elif entry['type'] == "NETWORK-ELB-TargetGroup":
            # Creating ELB boto3 client
            elb_client_v2_release = boto3.client('elbv2')
            # Deleting/releasing the target group (AWS account)
            response = elb_client_v2_release.delete_target_group(TargetGroupArn=entry['arn'])

        else:
            # Creating ELB boto3 client
            elb_client_v2_release = boto3.client('elbv2')
            # Deleting/releasing application/network/gateway load balancer on AWS account
            response = elb_client_v2_release.delete_load_balancer(LoadBalancerArn=entry['arn'])
            # Deleting/releasing the target group (AWS account)
            response = elb_client_v2_release.delete_target_group(TargetGroupArn=entry['tg_arn'])

        # Creating DynamoDB client
        dynamodb_client = boto3.resource('dynamodb')
        table = dynamodb_client.Table('resources')
        # Deleting/releasing the entry (DynamoDB)
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
            "body": json.dumps('ELB Record deleted')
        }

