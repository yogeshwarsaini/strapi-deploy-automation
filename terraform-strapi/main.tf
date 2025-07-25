provider "aws" {
  region = "us-east-2"
}

# 🔹 Get default VPC and subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 🔹 Security group for EC2 (Strapi port + SSH)
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg-shyam"
  description = "Allow ports for Strapi and SSH"

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🔹 Security group for ALB (HTTP 80)
resource "aws_security_group" "alb_sg" {
  name        = "strapi-alb-sg-v3"
  description = "Allow HTTP traffic"

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
}

# 🔹 EC2 Instance with Strapi
resource "aws_instance" "strapi_ec2" {
  ami                    = "ami-0cd582ee8a22cc7be" # Ubuntu 22.04
  instance_type          = "t2.micro"
  key_name               = "shyam"
  vpc_security_group_ids = [
    aws_security_group.strapi_sg.id,
    aws_security_group.alb_sg.id
  ]

  user_data = file("user_data.sh") # Make sure this file sets up Docker + Strapi

  tags = {
    Name = "StrapiServer"
  }
}

# 🔹 Application Load Balancer
resource "aws_lb" "strapi_alb" {
  name               = "strapi-alb-v2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids
}

# 🔹 Target Group
resource "aws_lb_target_group" "strapi_tg" {
  name        = "strapi-tg-v3"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    path                = "/"
    port                = "1337"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# 🔹 Listener to forward port 80 to EC2:1337
resource "aws_lb_listener" "strapi_listener" {
  load_balancer_arn = aws_lb.strapi_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi_tg.arn
  }
}

# 🔹 Attach EC2 instance to Target Group
resource "aws_lb_target_group_attachment" "strapi_attachment" {
  target_group_arn = aws_lb_target_group.strapi_tg.arn
  target_id        = aws_instance.strapi_ec2.id
  port             = 1337
}

# 🔹 Output ALB DNS
output "alb_dns" {
  value = aws_lb.strapi_alb.dns_name
}
