# filepath: /aws-vpc-setup/scripts/vpc-setup.sh
# Creating a VPC with a CIDR block of 10.0.0.0/24

vpcid=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/26 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=myVPC}]' \
    --query 'Vpc.VpcId' \
    --output text)

echo "VPC created: $vpcid"

