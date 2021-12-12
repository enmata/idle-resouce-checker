from datetime import datetime
import boto3
import json
from botocore.exceptions import ClientError
from lambda_model_elb import Elb


def lambda_handler(event, context):

    # Creating ELB (new v2 version) boto3 client
    elbv2_client = boto3.client('elbv2')
    # Creating ELB (for Classic Load balancers) boto3 client
    elbv1_client = boto3.client('elb')
    # Creating DynamoDB client
    dynamodb_client = boto3.resource('dynamodb')
    table = dynamodb_client.Table('resources')

    try:
        # Creating Elb list to be added
        lb_list: List[Elb] = []

        # Getting all target groups
        tg_description = elbv2_client.describe_target_groups()
        for tg in tg_description['TargetGroups']:
            tg_arn_dict = []
            tg_arn_dict.append([tg['TargetGroupName'], tg['TargetGroupArn'], tg['LoadBalancerArns'],
                                tg['TargetGroupArn'].split(':')[4]])

            # checking each target groups, if has target (if target health has something set)
            for tga in tg_arn_dict:
                th_description = elbv2_client.describe_target_health(TargetGroupArn=tga[1])

                # checking if target health has any load balancer assigned/set or is orphan
                if len(th_description['TargetHealthDescriptions']) == 0:
                    # checking if target group is linked to any load balancer
                    if len(tg['LoadBalancerArns']) > 0:
                        lb_name = tg['LoadBalancerArns'][0]
                        if 'app/' in lb_name:
                            lb_type = "NETWORK-ELB-ApplicationLB"
                        elif 'net/' in lb_name:
                            lb_type = "NETWORK-ELB-NetworkLB"
                        else:
                            lb_type = "NETWORK-ELB-GatewayLB"

                        elb_to_add = Elb(lb_name=tg['LoadBalancerArns'][0].split('/')[2],
                                           lb_arn=tg['LoadBalancerArns'][0],
                                           tg_arn=tg['TargetGroupArn'],
                                           type=lb_type,
                                           available_from=str(datetime.now()),
                                           region=tg['TargetGroupArn'].split(':')[3],
                                           account=tg['TargetGroupArn'].split(':')[4])

                    # orphan target groups
                    else:
                        elb_to_add = Elb(lb_name="ELB_None_name",
                                           lb_arn="ELB_None_arn",
                                           tg_arn=tg['TargetGroupArn'],
                                           type="NETWORK-ELB-TargetGroup",
                                           available_from=str(datetime.now()),
                                           region=tg['TargetGroupArn'].split(':')[3],
                                           account=tg['TargetGroupArn'].split(':')[4])

                else:
                    # orphan target groups
                    if len(tg['LoadBalancerArns']) == 0:
                        elb_to_add = Elb(lb_name="ELB_None_name",
                                        lb_arn="ELB_None_arn",
                                        tg_arn=tg['TargetGroupArn'],
                                        type="NETWORK-ELB-TargetGroup",
                                        available_from=str(datetime.now()),
                                        region=tg['TargetGroupArn'].split(':')[3],
                                        account=tg['TargetGroupArn'].split(':')[4])
                lb_list.append(elb_to_add)


        # Getting load classic balancers
        lb_descriptions = elbv1_client.describe_load_balancers()
        # Formating results
        for lb in lb_descriptions['LoadBalancerDescriptions']:
            if len(lb['Instances']) == 0:
                elb_to_add = Elb(lb_name=lb['LoadBalancerName'],
                                   lb_arn="arn:aws:elasticloadbalancing:{}:{}:loadbalancer/{}".format(
                                       lb['AvailabilityZones'][0][:-1],
                                       context.invoked_function_arn.split(':')[4],
                                       lb['LoadBalancerName']),
                                   tg_arn="Classic_None_tg",
                                   type="NETWORK-ELB-ClassicLB",
                                   available_from=str(datetime.now()),
                                   region=str(lb['AvailabilityZones'][0])[:-1],
                                   account=context.invoked_function_arn.split(':')[4])
                lb_list.append(elb_to_add)


        # Adding elb items found on DynamoDB table
        for elb in lb_list:
            table.put_item(
                Item={
                    'arn': elb.lb_arn,
                    'type': elb.type,
                    'lb_name': elb.lb_name,
                    'tg_arn': elb.tg_arn,
                    'available_from': elb.available_from,
                    'region': elb.region,
                    'account': elb.account
                }
            )

    except ClientError as e:
        print(e.response['Error']['Message'])

    else:
        return {
            "statusCode": 200,
            "body": json.dumps('ELBs scanned')
        }


