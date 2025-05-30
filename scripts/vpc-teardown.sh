#!/bin/bash

#@author: Pavel Losiev
#@description: Basic teardown script that deletes the VPC and all related resources.
#@date: 2025-25-05
#@version: 1.0
#@dependencies: AWS CLI, jq, curl

# Terminate EC2s → Delete NAT Gateway → Release EIP → Detach/Delete IGW → Delete subnets/route tables/SGs → Delete VPC.


#############################################
# Set your VPC ID (or retrieve dynamically)
vpcid=$(aws ec2 describe-vpcs \
    --filters "Name=tag:Name,Values=myVPC" \
    --query "Vpcs[0].VpcId" \
    --output text)

# Terminate EC2 instances at first 
# beause AWS will not let you detach or delete an Internet Gateway
# while there are resources (like EC2 instances or NAT Gateways)
# in the VPC with public IP addresses.
instances=$(aws ec2 describe-instances \
    --filters "Name=vpc-id,Values=$vpcid" \
    --query "Reservations[].Instances[].InstanceId" \
    --output text)
if [ -n "$instances" ]; then
    aws ec2 terminate-instances --instance-ids $instances
    aws ec2 wait instance-terminated --instance-ids $instances
    echo "Terminated EC2 instances: $instances"
fi

# Delete NAT Gateway and release Elastic IP
natgw=$(aws ec2 describe-nat-gateways \
    --filter "Name=vpc-id,Values=$vpcid" \
    --query "NatGateways[0].NatGatewayId" \
    --output text)
if [ "$natgw" != "None" ]; then
#   eipalloc=$(aws ec2 describe-nat-gateways \
#     --nat-gateway-ids $natgw \
#     --query "NatGateways[0].NatGatewayAddresses[0].AllocationId" \
#     --output text)

    # The logic in this code is incorrect. The while loop condition is wrong - 
# it continues looping when the NAT Gateway is deleted, which is the opposite of what we want.
# Here is the corrected version:
aws ec2 delete-nat-gateway --nat-gateway-id $natgw
echo "Waiting for NAT Gateway $natgw to disappear..."
while aws ec2 describe-nat-gateways \
        --nat-gateway-ids $natgw \
        --query 'NatGateways[].State' \
        --output text | grep -v "deleted" > /dev/null; do
    echo "NAT Gateway status: $(aws ec2 describe-nat-gateways --nat-gateway-ids $natgw --query 'NatGateways[].State' --output text)"
    sleep 5
done
echo "Deleted NAT Gateway: $natgw"
    # "Release the Elastic IP"- feature is commented out
    # because it eed the correct IAM permissions to release Elastic IPs.
    # Make sure your user/role has ec2:ReleaseAddress.

    # Uncomment the following lines if you have the necessary permissions
    #   if [ "$eipalloc" != "None" ]; then
    #     aws ec2 release-address --allocation-id $eipalloc
    #   fi
fi

# Delete all network interfaces (except the default ones)
enis=$(aws ec2 describe-network-interfaces --filters "Name=vpc-id,Values=$vpcid" --query "NetworkInterfaces[].NetworkInterfaceId" --output text)
for eni in $enis; do
    aws ec2 delete-network-interface --network-interface-id $eni
    echo "Deleted Network Interface: $eni"
done

# Detach and delete Internet Gateway
igw=$(aws ec2 describe-internet-gateways \
    --filters "Name=attachment.vpc-id,Values=$vpcid" \
    --query "InternetGateways[0].InternetGatewayId" \
    --output text)
if [ "$igw" != "None" ]; then
    aws ec2 detach-internet-gateway --internet-gateway-id $igw --vpc-id $vpcid
    aws ec2 delete-internet-gateway --internet-gateway-id $igw
    echo "Deleted Internet Gateway: $igw"
fi
  

# Delete subnets
subnets=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$vpcid" \
    --query "Subnets[].SubnetId" \
    --output text)
for subnet in $subnets; do
    aws ec2 delete-subnet \
    --subnet-id $subnet
    echo "Deleted Subnet: $subnet"
done

# Delete route tables (only non-main ones associated with this VPC)
rts=$(aws ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=$vpcid" \
    --query "RouteTables[?!Associations[?Main==\`true\`]].RouteTableId" \
    --output text)
for rt in $rts; do
    # First, disassociate any subnet associations
    assocs=$(aws ec2 describe-route-tables \
        --route-table-id $rt \
        --query "RouteTables[0].Associations[?!Main].AssociationId" \
        --output text)
    for assoc in $assocs; do
        [ -n "$assoc" ] && aws ec2 disassociate-route-table --association-id $assoc
        echo "Disassociated route table association: $assoc"
    done
    
    # Then delete the route table
    aws ec2 delete-route-table --route-table-id $rt
    echo "Deleted Route Table: $rt"
done

# Delete security groups (except default)
sgs=$(aws ec2 describe-security-groups \
    --filters "Name=vpc-id,Values=$vpcid" \
    --query "SecurityGroups[?GroupName!='default'].GroupId" \
    --output text)
for sg in $sgs; do
    aws ec2 delete-security-group --group-id $sg
    echo "Deleted Security Group: $sg"
done

aws ec2 delete-vpc \
    --vpc-id $vpcid

echo "VPC and all related resources have been deleted."