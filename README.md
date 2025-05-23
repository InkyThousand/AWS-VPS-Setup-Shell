# AWS VPC Setup Project

This project sets up an AWS Virtual Private Cloud (VPC). It includes one public subnet and one private subnet, along with an Internet Gateway for the public subnet.

## Project Structure

```
aws-vpc-setup
├── scripts
│   └── vpc-setup.sh        # Bash script to set up the VPC
└── README.md               # Project documentation
```

## Prerequisites

- AWS CLI installed and configured with appropriate permissions.
- Access to an AWS account to create resources.

## Networks Setup

VPC: 10.0.0.0/24 (provides 256 IPs)
Private Subnet: 10.0.0.0/26 (62 usable IPs)
Public Subnet: 10.0.0.64/28 (14 usable IPs)

## Running the Script

To set up the VPC using the provided Bash script, follow these steps:

1. Open a terminal and navigate to the `scripts` directory:
   ```
   cd aws-vpc-setup/scripts
   ```

2. Make the script executable:
   ```
   chmod +x vpc-setup.sh
   ```

3. Run the script:
   ```
   ./vpc-setup.sh
   ```
