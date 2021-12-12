#!/bin/bash

# Setting AWS account variables
export SUBNET_ID="subnet-XXXXXX"
export SEC_GROUP="sg-XXXXX"
export NETWORK_BORDER_GROUP="eu-west-1"

# ENIs
# CREATING ENIS
#https://docs.aws.amazon.com/cli/latest/reference/ec2/create-network-interface.html
echo "[test-generate] Creating dummy enis..."
aws ec2 create-network-interface --subnet-id $SUBNET_ID --description "ENI-empty-1" --groups $SEC_GROUP > /dev/null
aws ec2 create-network-interface --subnet-id $SUBNET_ID --description "ENI-empty-2" --groups $SEC_GROUP > /dev/null

# LISTING ENIS
#https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-network-interfaces.html
#echo "[test-generate] Listing dummy enis...\n"
#aws ec2 describe-network-interfaces --filters=Name=subnet-id,Values=$SUBNET_ID > /dev/null

# DELETING ENIS
#https://docs.aws.amazon.com/cli/latest/reference/ec2/delete-network-interface.html
#echo "[test-generate] Deleting dummy enis...\n"
#aws ec2 delete-network-interface --network-interface-id eni-05a4ec81e9e99ed58 > /dev/null


# ELBs
# CREATING ELBS
# https://docs.aws.amazon.com/cli/latest/reference/elb/create-load-balancer.html
echo "[test-generate] Creating dummy elbs..."
aws elb create-load-balancer --load-balancer-name ELBClassic-ToDelete --listeners --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --subnets $SUBNET_ID  > /dev/null

# Listing ELBs
#https://docs.aws.amazon.com/cli/latest/reference/elb/describe-load-balancers.html
#echo "[test-generate] Listing dummy elbs...\n"
#aws elb describe-load-balancers --load-balancer-name ELBClassic-ToDelete > /dev/null

# Deleting ELBs
#https://docs.aws.amazon.com/cli/latest/reference/elb/delete-load-balancer.html
#echo "[test-generate] Deleting dummy elbs...\n"
#aws elb delete-load-balancer --load-balancer-name ELBClassic-ToDelete > /dev/null


# EIPs
# Creating EIPs
#https://docs.aws.amazon.com/cli/latest/reference/ec2/allocate-address.html
echo "[test-generate] Creating dummy eips..."
aws ec2 allocate-address --domain vpc --network-border-group $NETWORK_BORDER_GROUP > /dev/null
aws ec2 allocate-address --domain vpc --network-border-group $NETWORK_BORDER_GROUP > /dev/null

# Listing EIPs
#https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-addresses.html
#echo "[test-generate] Listing dummy eips...\n"
#aws ec2 describe-addresses --filters "Name=domain,Values=vpc" > /dev/null

# Deleting EIPs
#https://docs.aws.amazon.com/cli/latest/reference/ec2/release-address.html
#echo "[test-generate] Deleting dummy elbs...\n"
#aws ec2 release-address --allocation-id eipalloc-025ed3328e1e92991 > /dev/null
