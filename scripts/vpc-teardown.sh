#!/bin/bash

#@author: Pavel Losiev
#@description: Basic teardown script that deletes the VPC and all related resources.
#@date: 2025-25-05
#@version: 1.0
#@dependencies: AWS CLI, jq, curl

#############################################
# Set your VPC ID (or retrieve dynamically)
vpcid=$(aws ec2 describe-vpcs \
    --filters "Name=tag:Name,Values=myVPC" \
    --query "Vpcs[0].VpcId" \
    --output text)

# Detach and delete Internet Gateway
igw=$(aws ec2 describe-internet-gateways \
    --filters "Name=attachment.vpc-id,Values=$vpcid" \
    --query "InternetGateways[0].InternetGatewayId" \
    --output text)

if [ "$igw" != "None" ]; then
  aws ec2 detach-internet-gateway --internet-gateway-id $igw --vpc-id $vpcid
  aws ec2 delete-internet-gateway --internet-gateway-id $igw
fi

# Delete NAT Gateway and release Elastic IP
natgw=$(aws ec2 describe-nat-gateways \
    --filter Name=vpc-id,Values=$vpcid \
    --query "NatGateways[0].NatGatewayId" \
    --output text)

if [ "$natgw" != "None" ]; then
  eipalloc=$(aws ec2 describe-nat-gateways \
    --nat-gateway-ids $natgw \
    --query "NatGateways[0].NatGatewayAddresses[0].AllocationId" \
    --output text)

  aws ec2 delete-nat-gateway \
    --nat-gateway-id $natgw
  
  # Wait for NAT Gateway deletion
  aws ec2 wait nat-gateway-deleted \
    --nat-gateway-ids $natgw
  if [ "$eipalloc" != "None" ]; then
    aws ec2 release-address \
        --allocation-id $eipalloc
  fi
fi

# Delete subnets
subnets=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$vpcid" \
    --query "Subnets[].SubnetId" \
    --output text)
for subnet in $subnets; do
  aws ec2 delete-subnet \
    --subnet-id $subnet
done

# Delete route tables (except the main one)
rts=$(aws ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=$vpcid" \
    --query "RouteTables[?Associations[?Main!=`true`]].RouteTableId" \
    --output text)
for rt in $rts; do
  aws ec2 delete-route-table --route-table-id $rt
done

# Delete security groups (except default)
sgs=$(aws ec2 describe-security-groups \
    --filters "Name=vpc-id,Values=$vpcid" \
    --query "SecurityGroups[?GroupName!='default'].GroupId" \
    --output text)
for sg in $sgs; do
  aws ec2 delete-security-group --group-id $sg
done

# # Terminate EC2 instances
# instances=$(aws ec2 describe-instances --filters "Name=vpc-id,Values=$vpcid" --query "Reservations[].Instances[].InstanceId" --output text)
# if [ -n "$instances" ]; then
#   aws ec2 terminate-instances --instance-ids $instances
#   aws ec2 wait instance-terminated --instance-ids $instances
# fi

# Finally, delete the VPC
aws ec2 delete-vpc \
    --vpc-id $vpcid

echo "VPC and all related resources have been deleted."