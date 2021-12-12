import boto3


def lambda_handler(event, context):

    if event['type'] == "NETWORK-ELB-ClassicLB":
        # Creating Classic ELB boto3 client
        elb_client_v1_release = boto3.client('elb')
        # Deleting/releasing the elb (AWS account)
        response = elb_client_v1_release.delete_load_balancer(LoadBalancerName=event['lb_name'])

    elif event['type'] == "NETWORK-ELB-TargetGroup":
        # Creating ELB boto3 client
        elb_client_v2_release = boto3.client('elbv2')
        # Deleting/releasing the target group (AWS account)
        response = elb_client_v2_release.delete_target_group(TargetGroupArn=event['arn'])

    else:
        # Creating ELB boto3 client
        elb_client_v2_release = boto3.client('elbv2')
        # Deleting/releasing application/network/gateway load balancer on AWS account
        response = elb_client_v2_release.delete_load_balancer(LoadBalancerArn=event['arn'])
        # Deleting/releasing the target group (AWS account)
        response = elb_client_v2_release.delete_target_group(TargetGroupArn=event['tg_arn'])

    # Creating DynamoDB client
    dynamodb_client = boto3.resource('dynamodb')
    table = dynamodb_client.Table('resources')
    # Deleting/releasing the entry (DynamoDB)
    table.delete_item(
        Key={
            'arn': event['arn'],
            'type': event['type'],
        }
    )

    return {
        'statusCode': response['ResponseMetadata']['HTTPStatusCode'],
        'body': 'Entry deleted'
    }
