#!/bin/bash

#@author: Pavel Losiev
#@description: PHASE 2 - EC2 Instance Launch with User Data.
#@date: 2025-25-05
#@usage: ./instances-setup.sh
#@dependencies: AWS CLI, jq, curl

#############################################

# Load VPC, Subnet IDs and Security Group from Phase 1 output
vpcid=$(aws ec2 describe-vpcs \
  --filters Name=tag:Name,Values=myVPC \
  --query 'Vpcs[0].VpcId' \
  --output text)

pubsub1=$(aws ec2 describe-subnets \
  --filters "Name=tag:Name,Values='Public Subnet'" "Name=vpc-id,Values=$vpcid" \
  --query 'Subnets[0].SubnetId' \
  --output text)

privsub1=$(aws ec2 describe-subnets \
  --filters "Name=ctag:Name,Values='Privat Subnet'" "Name=vpc-id,Values=$vpcid" \
  --query 'Subnets[0].SubnetId' \
  --output text)

sgid=$(aws ec2 describe-security-groups \
  --filters "Name=tag:Name,Values='mySecurityGroup'" "Name=vpc-id,Values=$vpcid" \
  --query 'SecurityGroups[0].GroupId' \
  --output text)

# Check if VPC, Subnet IDs and Security Group are found
if [ -z "$vpcid" ] || [ -z "$pubsub1" ] || [ -z "$privsub1" ] || [ -z "$sgid" ]; then
  echo "Error: VPC, Subnet IDs or Security Group not found. Please run the VPC setup script first."
  exit 1
fi

# Launch an EC2 instance in the public subnet