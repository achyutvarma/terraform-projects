# Networking Module

This module provisions the shared network layer for an environment.

Resources created:
- VPC
- Public subnets
- Private subnets
- Internet gateway
- One NAT gateway per public subnet / AZ
- Public route table
- One private route table per private subnet / AZ
- Route table associations

Inputs:
- `vpc_cidr`
- `public_subnet_cidrs`
- `private_subnet_cidrs`
- `availability_zones`
- `naming_prefix`
- `common_tags`

Outputs:
- `vpc_id`
- `public_subnet_ids`
- `private_subnet_ids`
- `nat_gateway_id`

Design notes:
- Public subnets route internet traffic through the internet gateway.
- Each private subnet routes outbound internet traffic through the NAT gateway in the matching AZ.
- This improves availability compared with a single shared NAT gateway.
