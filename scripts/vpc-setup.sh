# filepath: /aws-vpc-setup/scripts/vpc-setup.sh
# Creating a VPC with a CIDR block of 10.0.0.0/24

vpcid=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/25 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=myVPC}]' \
    --query 'Vpc.VpcId' \
    --output text)

echo "VPC created: $vpcid"

# Create Private Subnet

privsub1=$(aws ec2 create-subnet \
  --vpc-id $vpcid \
  --cidr-block 10.0.0.0/26 \
  --availability-zone us-west-2a \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private Subnet}]' \
  --query 'Subnet.SubnetId' \
  --output text)

echo "Private Subnet created: $privsub1"

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

# Create Internet Gateway
igw=$(aws ec2 create-internet-gateway \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=myIGW}]' \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)
echo "Internet Gateway created: $igw"

# Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway \
  --vpc-id $vpcid \
  --internet-gateway-id $igw

echo "Internet Gateway attached to VPC $vpcid"
