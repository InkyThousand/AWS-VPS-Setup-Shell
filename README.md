# AWS VPC Setup Project

This project sets up an AWS Virtual Private Cloud (VPC). It includes one public subnet and one private subnet, along with an Internet Gateway for the public subnet.

## Project Structure

```
aws-vpc-setup
├── scripts
│   └── vpc-setup.sh        # Bash script to set up the VPC
|   └── instances-setup.sh  # Bash script to EC2 Instances Lanch
└── README.md               # Project documentation
```
## Project Phases

| Phase | Description                                                  | File                        |
|-------|--------------------------------------------------------------|-----------------------------|
| 01    | VPC, Subnet Setup Routing, NAT Gateway Configuration and     | scripts/vpc-setup.sh        |
|       | Security Groups Setup                                        |                             |
| 02    | EC2 Instance Launch with User Data                           | scripts/instances-setup.sh  |


## Prerequisites

- AWS CLI installed and configured with appropriate permissions.
- AWS IAM permissions to create VPCs, subnets, route tables, gateways, security groups, and EC2 instances.

## Network Setup

| Resource            | CIDR             | AZ           | Notes                                          |
|---------------------|------------------|--------------|------------------------------------------------|
| **VPC**             | `10.0.0.0/25`    | —            | Name: `myVPC`                                  |
| **Public Subnet**   | `10.0.0.64/28`   | `us-*-*a`    | Auto-assign Public IPv4, Name: `Public Subnet` |
| **Private Subnet**  | `10.0.0.0/26`    | `us-*-*a`    | Name: `Private Subnet`                         |

---

## AWS Resources

- **Internet Gateway**  
  - ID: `myIGW`  
  - Attached to: `myVPC`

- **NAT Gateway**  
  - ID: `myNATGateway`  
  - Subnet: `Public Subnet`  
  - Elastic IP: auto-allocated

- **Route Tables**  
  1. **Public Route Table** (`myPublic RouteTable`)  
     - Associated Subnet: `Public Subnet`  
     - Routes:  
       - `0.0.0.0/0` → `myIGW`  
  2. **Private Route Table** (`myPrivate RouteTable`)  
     - Associated Subnet: `Private Subnet`  
     - Routes:  
       - `0.0.0.0/0` → `myNATGateway`

- **Security Group** (`mySecurityGroup`)  
  - Ingress:  
    - SSH (TCP 22) from your IP only: `<YOUR_PUBLIC_IP>/32`  
  - Egress:  
    - All outbound TCP/UDP/ICMP


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

<!-- ## Cleanup
To delete all resources when finished:
```
./vpc-teardown.sh
```
Warning: This will destroy the VPC, subnets, gateways, and route tables you created. -->

## License & Acknowledgments

Script authored by Pavel Losiev
Built with ❤️ on AWS
Uses AWS best practices for network isolation and security

> Feel free to fill in any missing IDs or AZ names, and update the diagram section with your preferred visual.