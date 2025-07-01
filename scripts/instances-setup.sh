#!/bin/bash

#@author: Pavel Losiev
#@description: PHASE 2 - EC2 Instance Launch with User Data.
#@date: 2025-25-05
#@usage: ./instances-setup.sh
#@dependencies: AWS CLI, jq, curl

#############################################

# Get the current public IP address
myip=$(curl -s http://checkip.amazonaws.com)/32
echo "My IP address is: $myip"

# Load VPC, Subnet IDs and Security Group from Phase 1 output
vpcid=$(aws ec2 describe-vpcs \
  --filters Name=tag:Name,Values=myVPC \
  --query 'Vpcs[0].VpcId' \
  --output text)

# Get the Subnet IDs
pubsub1=$(aws ec2 describe-subnets \
  --filters "Name=tag:Name,Values='Public Subnet'" "Name=vpc-id,Values=$vpcid" \
  --query 'Subnets[0].SubnetId' \
  --output text)

# Get the Private Subnet ID
privsub1=$(aws ec2 describe-subnets \
  --filters "Name=tag:Name,Values='Private Subnet'" "Name=vpc-id,Values=$vpcid" \
  --query 'Subnets[0].SubnetId' \
  --output text)

# Check if VPC, Subnet IDs and Security Group are found
if [ -z "$vpcid" ] || [ -z "$pubsub1" ] || [ -z "$privsub1" ]; then
  echo "Error: VPC or Subnet IDs not found. Please run the VPC setup script first."
  exit 1
fi

# Print the IDs for verification
echo "VPC ID: $vpcid"
echo "Public Subnet ID: $pubsub1"
echo "Private Subnet ID: $privsub1"

###################################3

# Create Security Group
bastion_sg=$(aws ec2 create-security-group \
  --group-name mySecurityGroup \
  --description "Security group for Bastion host - Restrict security group ingress to my IP" \
  --vpc-id $vpcid \
  --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=BastionSecurityGroup}]' \
  --query 'GroupId' \
  --output text)
echo "Security Group created: $bastion_sg"

# Add Inbound Rules to Security Group enabling SSH access from my IP
aws ec2 authorize-security-group-ingress \
  --group-id $bastion_sg \
  --protocol tcp \
  --port 22 \
  --cidr $myip
echo "Inbound rule added to Security Group $bastion_sg allowing SSH access from $myip"


# Get the latest Amazon Linux 2023 AMI ID with SSM Parameter 
al2023_ami=$(aws ssm get-parameter \
    --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64 \
    --query "Parameter.Value" \
    --output text)
echo "Latest Amazon Linux 2023 AMI: $al2023_ami"

# Get avalable key pair
keypair=$(aws ec2 describe-key-pairs \
  --query 'KeyPairs[0].KeyName' \
  --output text)

# !NEED TO CHECK Check if a key pair exists
if [ $keypair == "None" ] || [ $keypair != "vockey" ]; then
  echo "No key pair found. Creating a new key pair."
  # Create key pair
  aws ec2 create-key-pair \
    --key-name myKeyPair \
    --query 'KeyMaterial' \
    --output text > myKeyPair.pem
else
  echo "Using existing key pair: $keypair"
fi

# Launch an Bastion EC2 instance in the public subnet
instance_id=$(aws ec2 run-instances \
  --image-id $al2023_ami \
  --instance-type t2.micro \
  --key-name $keypair \
  --security-group-ids $bastion_sg \
  --subnet-id $pubsub1 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=BastionServer}]' \
  --query 'Instances[0].InstanceId' \
  --output text
)

echo "BastionServer launched: $instance_id"
