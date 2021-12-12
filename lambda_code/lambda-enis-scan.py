from datetime import datetime
import boto3
import json
from botocore.exceptions import ClientError
from lambda_model_eni import Eni


def lambda_handler(event, context):

    # Creating ENI boto3 client
    ec2_client = boto3.client('ec2')
    # Creating ENI boto3 client
    dynamodb_client = boto3.resource('dynamodb')
    table = dynamodb_client.Table('resources')

    try:
        # creating enis list
        eni_list: List[Eni] = []

        # Getting all network interfaces
        eni_dict = ec2_client.describe_network_interfaces()

        # Getting all network interfaces
        for eni_iface in eni_dict["NetworkInterfaces"]:
            if 'Association' in eni_iface:
                # Adding Elastic Load Balancer interfaces
                if eni_iface['Association']['IpOwnerId'] == "amazon-elb":
                    eni_list.append(Eni(eni_id=eni_iface['NetworkInterfaceId'],
                                        private_ip=eni_iface['PrivateIpAddress'],
                                        public_ip=eni_iface['Association']['PublicIp'],
                                        mac_address=eni_iface['MacAddress'],
                                        type="NETWORK-ENI-ELB",
                                        resource_name=eni_iface['Description'],
                                        available_from=datetime.now(),
                                        region=eni_iface['AvailabilityZone'],
                                        account=eni_iface['OwnerId']))

                # Adding RDS managed RD interfaces
                elif eni_iface['Association']['IpOwnerId'] == "amazon-rds":
                    rds_name: str = ''
                    if (("DB" in eni_iface['Groups'][0]['GroupName']) or ("db" in eni_iface['Groups'][0]['GroupName'])):
                        rds_name = str(eni_iface['Groups'][0]['GroupName']).split('-')[0]
                    else:
                        rds_name = eni_iface['Groups'][0]['GroupName']

                    eni_list.append(Eni(eni_id=eni_iface['NetworkInterfaceId'],
                                        private_ip=eni_iface['PrivateIpAddress'],
                                        public_ip=eni_iface['Association']['PublicIp'],
                                        mac_address=eni_iface['MacAddress'],
                                        type="NETWORK-ENI-RDS",
                                        resource_name=rds_name,
                                        available_from=str(datetime.now()),
                                        region=eni_iface['AvailabilityZone'],
                                        account=eni_iface['OwnerId']))

                # Adding NAT Gateway interfaces
                elif eni_iface['InterfaceType'] == "nat_gateway":
                    eni_list.append(Eni(eni_id=eni_iface['NetworkInterfaceId'],
                                        private_ip=eni_iface['PrivateIpAddress'],
                                        public_ip=eni_iface['Association']['PublicIp'],
                                        mac_address=eni_iface['MacAddress'],
                                        type="NETWORK-ENI-NATGateway",
                                        resource_name=eni_iface['Description'][26:],
                                        available_from=str(datetime.now()),
                                        region=eni_iface['AvailabilityZone'],
                                        account=eni_iface['OwnerId']))

                # Adding EC2 instances interfaces
                elif "PublicIp" in eni_iface['Association']:
                    eni_list.append(Eni(eni_id=eni_iface['NetworkInterfaceId'],
                                        private_ip=eni_iface['PrivateIpAddress'],
                                        public_ip=eni_iface['Association']['PublicIp'],
                                        mac_address=eni_iface['MacAddress'],
                                        type="NETWORK-ENI-EC2Public",
                                        resource_name= eni_iface['Attachment']['InstanceId'] if ("Attachment" in eni_iface) else "None",
                                        available_from=str(datetime.now()),
                                        region=eni_iface['AvailabilityZone'],
                                        account=eni_iface['OwnerId']))

                else:
                    eni_list.append(Eni(eni_id=eni_iface['NetworkInterfaceId'],
                                        private_ip=eni_iface['PrivateIpAddress'],
                                        public_ip="None",
                                        mac_address=eni_iface['MacAddress'],
                                        type="NETWORK-ENI-EC2Private",
                                        resource_name=eni_iface['Attachment']['InstanceId'],
                                        available_from=str(datetime.now()),
                                        region=eni_iface['AvailabilityZone'],
                                        account=eni_iface['OwnerId']))

            # Adding ec2 instances interfaces
            else:
                if "PublicIp" in eni_iface:
                    eni_list.append(Eni(eni_id=eni_iface['NetworkInterfaceId'],
                                        private_ip=eni_iface['PrivateIpAddress'],
                                        public_ip=eni_iface['Association']['PublicIp'],
                                        mac_address=eni_iface['MacAddress'],
                                        type="NETWORK-ENI-EC2Public",
                                        resource_name=eni_iface['Attachment']['InstanceId'],
                                        available_from=str(datetime.now()),
                                        region=eni_iface['AvailabilityZone'],
                                        account=eni_iface['OwnerId']))
                else:
                    eni_to_add = Eni(eni_id=eni_iface['NetworkInterfaceId'],
                                     private_ip=eni_iface['PrivateIpAddress'],
                                     public_ip="None",
                                     mac_address=eni_iface['MacAddress'],
                                     type="NETWORK-ENI-EC2Private",
                                     resource_name=eni_iface['Attachment']['InstanceId'] if (
                                                 'Attachment' in eni_iface) else "None",
                                     available_from=str(datetime.now()),
                                     region=eni_iface['AvailabilityZone'],
                                     account=eni_iface['OwnerId'])
                    eni_list.append(eni_to_add)


        # Adding eni items found on DynamoDB table
        for eni in eni_list:
            response = table.put_item(
                Item={
                    'arn': eni.eni_id,
                    'private_ip': eni.private_ip,
                    'public_ip': eni.public_ip,
                    'mac_address': eni.mac_address,
                    'type': eni.type,
                    'resource_name': eni.resource_name,
                    'available_from': str(eni.available_from),
                    'region': eni.region,
                    'account': eni.account
                }
            )

    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        return {
            "statusCode": 200,
            "body": json.dumps('ENIs scanned')
        }
