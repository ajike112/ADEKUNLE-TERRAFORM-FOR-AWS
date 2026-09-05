
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
# Reference Existing Jenkins Master VPC (ECS)
############################################
data "aws_vpc" "ecs_vpc" {
  id = "vpc-02c37a159008c6f80"
}

############################################
# Public Subnet for Jenkins Agent
############################################
resource "aws_subnet" "jenkins_agent_subnet" {
  vpc_id                  = data.aws_vpc.ecs_vpc.id
  cidr_block              = "10.20.60.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false   # IMPORTANT: we will attach an EIP manually

  tags = {
    Name = "jenkins-agent-subnet"
  }
}

############################################
# Internet Gateway
############################################
data "aws_internet_gateway" "ecs_igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.ecs_vpc.id]
  }
}

############################################
# Route Table + Association
############################################
resource "aws_route_table" "jenkins_agent_rt" {
  vpc_id = data.aws_vpc.ecs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.ecs_igw.id
  }

  tags = {
    Name = "jenkins-agent-rt"
  }
}

resource "aws_route_table_association" "jenkins_agent_assoc" {
  subnet_id      = aws_subnet.jenkins_agent_subnet.id
  route_table_id = aws_route_table.jenkins_agent_rt.id
}

############################################
# Security Group for Jenkins Agent
############################################
resource "aws_security_group" "jenkins_agent_sg" {
  name        = "jenkins-agent-sg"
  description = "Security group for Jenkins agent EC2"
  vpc_id      = data.aws_vpc.ecs_vpc.id

  ingress {
    description = "Allow SSH from laptop and Jenkins master"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "98.194.47.86/32",      # your laptop
      "54.160.158.144/32"     # Jenkins master public IP
    ]
  }

  ingress {
    description = "Allow Jenkins master to connect via JNLP"
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["10.20.0.0/16"]
  }

ingress {
  description = "Allow SSH from Jenkins master inside VPC"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["10.20.0.0/16"]
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

resource "aws_iam_role_policy_attachment" "jenkins_agent_ecr_attach" {
  role       = aws_iam_role.jenkins_agent_role.name
  policy_arn = "arn:aws:iam::536697262404:policy/jenkins-ecr-push-policy"
}

resource "aws_iam_instance_profile" "jenkins_agent_profile" {
  name = "jenkins-agent-profile"
  role = aws_iam_role.jenkins_agent_role.name
}

############################################
# Jenkins Agent EC2 Instance
############################################
resource "aws_instance" "jenkins_agent" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.jenkins_agent_subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins_agent_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins_agent_profile.name
  key_name               = var.key_name

  user_data                   = file("${path.module}/userdata.sh")
  user_data_replace_on_change = true

  tags = {
    Name = "jenkins-agent"
  }
}

############################################
# Elastic IP for Jenkins Agent (Permanent IP)
############################################
resource "aws_eip" "jenkins_agent_eip" {
  vpc = true

  tags = {
    Name = "jenkins-agent-eip"
  }
}

############################################
# Associate EIP with Jenkins Agent EC2
############################################
resource "aws_eip_association" "jenkins_agent_eip_assoc" {
  allocation_id = aws_eip.jenkins_agent_eip.id
  network_interface_id = data.aws_network_interface.jenkins_agent_primary_eni.id
}


data "aws_network_interface" "jenkins_agent_primary_eni" {
  filter {
    name   = "attachment.instance-id"
    values = [aws_instance.jenkins_agent.id]
  }

  filter {
    name   = "attachment.device-index"
    values = ["0"]
  }
}
