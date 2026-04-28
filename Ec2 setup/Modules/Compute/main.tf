
# ---------------- ALB Security Group ----------------
resource "aws_security_group" "alb_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-alb-sg"
  })
}

# ---------------- EC2 Security Group ----------------
resource "aws_security_group" "ec2_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # only ALB can access
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-ec2-sg"
  })
}

# ---------------- Launch Template ----------------
resource "aws_launch_template" "lt" {
  name_prefix   = "${local.name_prefix}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -euxo pipefail

              apt update -y
              apt install -y nginx curl

              TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
                -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

              INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
                http://169.254.169.254/latest/meta-data/instance-id)

              AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
                http://169.254.169.254/latest/meta-data/placement/availability-zone)

              PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
                http://169.254.169.254/latest/meta-data/local-ipv4)

              cat > /var/www/html/index.html <<HTML
              <html>
                <head>
                  <title>Nginx Instance</title>
                </head>
                <body style="font-family: Arial; text-align: center; margin-top: 100px;">
                  <h1>Nginx is running</h1>
                  <h2>Instance ID: $INSTANCE_ID</h2>
                  <h2>Availability Zone: $AZ</h2>
                  <h2>Private IP: $PRIVATE_IP</h2>
                </body>
              </html>
              HTML

              systemctl enable nginx
              systemctl restart nginx
              EOF
          )

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${local.name_prefix}-nginx"
      Role = "web"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.common_tags, {
      Name = "${local.name_prefix}-nginx-volume"
    })
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-launch-template"
  })
}

# ---------------- Target Group ----------------
resource "aws_lb_target_group" "tg" {
  name     = local.tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(var.common_tags, {
    Name = local.tg_name
  })
}

# ---------------- ALB ----------------
resource "aws_lb" "alb" {
  name               = local.alb_name
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.alb_sg.id]

  tags = merge(var.common_tags, {
    Name = local.alb_name
  })
}

# ---------------- Listener ----------------
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# ---------------- Auto Scaling Group ----------------
resource "aws_autoscaling_group" "asg" {
  name             = local.asg_name
  desired_capacity = 2
  min_size         = 2
  max_size         = 3

  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-nginx"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

data "aws_instances" "asg_instances" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.asg.name]
  }

  depends_on = [aws_autoscaling_group.asg]
}
