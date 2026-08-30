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
  region = var.aws_region
}

# ─────────────────────────────────────────────────────────────
# Networking (VPC, subnets, security groups) for Jenkins
# ─────────────────────────────────────────────────────────────

resource "aws_vpc" "jenkins_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "jenkins-vpc"
  }
}

resource "aws_subnet" "jenkins_public_1" {
  vpc_id                  = aws_vpc.jenkins_vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.az_1
  map_public_ip_on_launch = true

  tags = {
    Name = "jenkins-public-1"
  }
}

resource "aws_subnet" "jenkins_public_2" {
  vpc_id                  = aws_vpc.jenkins_vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.az_2
  map_public_ip_on_launch = true

  tags = {
    Name = "jenkins-public-2"
  }
}

resource "aws_subnet" "jenkins_private_1" {
  vpc_id            = aws_vpc.jenkins_vpc.id
  cidr_block        = "10.20.20.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "jenkins-private-1"
  }
}

resource "aws_subnet" "jenkins_private_2" {
  vpc_id            = aws_vpc.jenkins_vpc.id
  cidr_block        = "10.20.21.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "jenkins-private-2"
  }
}


resource "aws_internet_gateway" "jenkins_igw" {
  vpc_id = aws_vpc.jenkins_vpc.id

  tags = {
    Name = "jenkins-igw"
  }
}


resource "aws_route_table" "jenkins_public_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_igw.id
  }

  tags = {
    Name = "jenkins-public-rt"
  }
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "jenkins_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.jenkins_public_1.id

  tags = {
    Name = "jenkins-nat-gateway"
  }
}

resource "aws_route_table" "jenkins_private_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.jenkins_nat.id
  }

  tags = {
    Name = "jenkins-private-rt"
  }
}

resource "aws_route_table_association" "jenkins_private_1_assoc" {
  subnet_id      = aws_subnet.jenkins_private_1.id
  route_table_id = aws_route_table.jenkins_private_rt.id
}

resource "aws_route_table_association" "jenkins_private_2_assoc" {
  subnet_id      = aws_subnet.jenkins_private_2.id
  route_table_id = aws_route_table.jenkins_private_rt.id
}


resource "aws_route_table_association" "jenkins_public_1_assoc" {
  subnet_id      = aws_subnet.jenkins_public_1.id
  route_table_id = aws_route_table.jenkins_public_rt.id
}

resource "aws_route_table_association" "jenkins_public_2_assoc" {
  subnet_id      = aws_subnet.jenkins_public_2.id
  route_table_id = aws_route_table.jenkins_public_rt.id
}

###########################################
# ALB SECURITY GROUP (PUBLIC FACING)
###########################################
resource "aws_security_group" "jenkins_alb_sg" {
  name        = "jenkins-alb-sg"
  description = "Public ALB SG for Jenkins"
  vpc_id      = aws_vpc.jenkins_vpc.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-alb-sg"
  }
}

#####################################
# EFS Security Group
#####################################
resource "aws_security_group" "jenkins_efs_sg" {
  name        = "jenkins-efs-sg"
  description = "Allow NFS from Jenkins ECS tasks"
  vpc_id      = aws_vpc.jenkins_vpc.id

  ingress {
    description     = "Allow NFS from Jenkins task SG"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_task_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-efs-sg"
  }
}


##########################################
# JENKINS ECS TASK SECURITY GROUP (PRIVATE)
##########################################

resource "aws_security_group" "jenkins_task_sg" {
  name        = "jenkins-task-sg"
  description = "Private SG for Jenkins ECS tasks"
  vpc_id      = aws_vpc.jenkins_vpc.id

  ingress {
    description     = "Allow ALB to reach Jenkins on port 8080"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_alb_sg.id]
  }

  ingress {
    description = "Allow NFS traffic to EFS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-task-sg"
  }
}



# ─────────────────────────────────────────────────────────────
# Call the Jenkins Fargate module
# ─────────────────────────────────────────────────────────────

module "jenkins_fargate" {
  source = "./modules/jenkins-fargate"
  aws_region = var.aws_region
  vpc_id = aws_vpc.jenkins_vpc.id

 private_subnet_ids = {
  private1 = aws_subnet.jenkins_private_1.id
  private2 = aws_subnet.jenkins_private_2.id
}

public_subnet_ids = [
  aws_subnet.jenkins_public_1.id,
  aws_subnet.jenkins_public_2.id
]

  
  alb_sg_id  = aws_security_group.jenkins_alb_sg.id
  task_sg_id = aws_security_group.jenkins_task_sg.id
  efs_sg_id  = aws_security_group.jenkins_efs_sg.id


  jenkins_fargate_cpu    = var.jenkins_fargate_cpu
  jenkins_fargate_memory = var.jenkins_fargate_memory
  jenkins_admin_user     =var.jenkins_admin_user
  jenkins_admin_pass     = var.jenkins_admin_pass
}
