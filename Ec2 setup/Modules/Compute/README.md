# Compute Module

This module provisions the application-facing compute layer for an environment.

Resources created:
- ALB security group
- EC2 security group
- Launch template
- Application target group
- Application Load Balancer
- Listener on port 80
- Auto Scaling Group

Inputs:
- `ami_id`
- `instance_type`
- `vpc_id`
- `public_subnet_ids`
- `private_subnet_ids`
- `my_ip`
- `key_name`
- `naming_prefix`
- `common_tags`

Outputs:
- `instance_ids`
- `alb_dns`
- `private_ips`

Design notes:
- The ALB is deployed in public subnets and forwards traffic to EC2 instances in private subnets.
- The launch template installs Nginx and writes instance metadata to the default page so load balancing is easy to verify.
- The target group includes an explicit HTTP health check on `/`.
