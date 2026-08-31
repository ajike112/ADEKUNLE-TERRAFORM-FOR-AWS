terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

############################################
# Dedicated VPC for Jenkins Agent
############################################
resource "aws_vpc" "jenkins_vpc" {
  cidr_block           = "10.50.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "jenkins-agent-vpc"
  }
}

############################################
# Internet Gateway
############################################
resource "aws_internet_gateway" "jenkins_igw" {
  vpc_id = aws_vpc.jenkins_vpc.id

  tags = {
    Name = "jenkins-agent-igw"
  }
}

############################################
# Public Subnet
############################################
resource "aws_subnet" "jenkins_public_subnet" {
  vpc_id                  = aws_vpc.jenkins_vpc.id
  cidr_block              = "10.50.10.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "jenkins-agent-public"
  }
}

############################################
# Route Table + Association
############################################
resource "aws_route_table" "jenkins_public_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_igw.id
  }

  tags = {
    Name = "jenkins-agent-public-rt"
  }
}

resource "aws_route_table_association" "jenkins_public_assoc" {
  subnet_id      = aws_subnet.jenkins_public_subnet.id
  route_table_id = aws_route_table.jenkins_public_rt.id
}

############################################
# Security Group for Jenkins Agent
############################################
resource "aws_security_group" "jenkins_agent_sg" {
  name        = "jenkins-agent-sg"
  description = "Security group for Jenkins agent EC2"
  vpc_id      = aws_vpc.jenkins_vpc.id

  ingress {
    description = "Allow Jenkins master to connect via JNLP"
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = var.jenkins_master_cidr
  }

  ingress {
    description = "SSH access from laptop"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-agent-sg"
  }
}

############################################
# IAM Role for Jenkins Agent
############################################
resource "aws_iam_role" "jenkins_agent_role" {
  name = "jenkins-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "jenkins_agent_policy" {
  name = "jenkins-agent-policy"
  role = aws_iam_role.jenkins_agent_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:*",
          "s3:*",
          "logs:*",
          "cloudwatch:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "jenkins_agent_profile" {
  name = "jenkins-agent-profile"
  role = aws_iam_role.jenkins_agent_role.name
}

############################################
# EC2 Instance
############################################
resource "aws_instance" "jenkins_agent" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.jenkins_public_subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins_agent_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins_agent_profile.name
  key_name               = var.key_name

  user_data = file("${path.module}/userdata.sh")

  tags = {
    Name = "jenkins-agent"
  }
}
