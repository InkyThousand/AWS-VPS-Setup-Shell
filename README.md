# AWS VPC Setup Project

This project sets up an AWS Virtual Private Cloud (VPC). It includes one public subnet and one private subnet, along with an Internet Gateway for the public subnet.

## Project Structure

```
aws-vpc-setup
├── scripts
│   └── vpc-setup.sh        # Bash script to set up the VPC
└── README.md               # Project documentation

## Prerequisites

- AWS CLI installed and configured with appropriate permissions.
- Access to an AWS account to create resources.

## Networks Setup

VPC: 10.0.0.0/24 (provides 256 IPs)
Private Subnet: 10.0.0.0/26 (62 usable IPs)
Public Subnet: 10.0.0.64/28 (14 usable IPs)