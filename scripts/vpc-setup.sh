# filepath: /aws-vpc-setup/scripts/vpc-setup.sh
# Creating a VPC with a CIDR block of 10.0.0.0/24

vpcid=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/26 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=myVPC}]' \
    --query 'Vpc.VpcId' \
    --output text)

echo "VPC created: $vpcid"

# Create Public Subnet

pubsub1=$(aws ec2 create-subnet \
  --vpc-id $vpcid \
  --cidr-block 10.0.0.64/28 \
  --availability-zone us-west-2a \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Public Subnet}]' \
  --query 'Subnet.SubnetId' \
  --output text)

echo "Public Subnet created: $pubsub1"

# Enable Public IP on launch

aws ec2 modify-subnet-attribute \
  --subnet-id $pubsub1 \
  --map-public-ip-on-launch

# Create Private Subnet

privsub1=$(aws ec2 create-subnet \
  --vpc-id $vpcid \
  --cidr-block 10.0.0.0/26 \
  --availability-zone us-west-2a \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private Subnet}]' \
  --query 'Subnet.SubnetId' \
  --output text)

echo "Private Subnet created: $privsub1"
