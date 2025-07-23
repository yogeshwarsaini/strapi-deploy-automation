provider "aws" {
  region = "us-east-2"
}

# resource "aws_key_pair" "deployer" {
#   key_name   = "shyam"
#   public_key = file("~/.ssh/id_rsa.pub")
# }

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

resource "aws_instance" "strapi_ec2" {
  ami             = "ami-0cd582ee8a22cc7be" # Example Ubuntu 22.04 AMI
  instance_type   = "t2.micro"
  key_name        = "shyam" # 👈 Existing key name
  security_groups = [aws_security_group.strapi_sg.name]

  user_data = file("user_data.sh")

  tags = {
    Name = "StrapiServer"
  }
}
