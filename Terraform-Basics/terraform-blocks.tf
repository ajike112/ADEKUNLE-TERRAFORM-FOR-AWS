
## This block is called TERRAFORM block. This block is meant to set contraint on terraform version.
## This is a terraform version constraint. It is not backward compatible (you should not use the lower version of terraform against the current version, otherwise, bugs might be introduced into your codes).

terraform {
    required_version = ">= 1.1.0" ## This sets the condition to ignore any terraform version below 1.1.0

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" ## This is the current AWS API version
    }
  }
}

## PROVIDER BLOCK. This block is mainly for authentication and authorization. We are basically allowing terraform to access our AWS
## This is the best practice for provider block
provider "aws" {
  region = "us-east-1"
  profile = "adekunle.ajike"
}


## RESOURCE BLOCK. This block is to create a resource.

## Create VPC
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

## Create Subnet
resource "aws_subnet" "private1" {
  ##vpc_id     = aws_vpc.main.id
  vpc_id     = local.vpc_id # call / reference the local
  cidr_block = var.subnet_cidr_1
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "private1"
  }
}

resource "aws_subnet" "private2" {
 ## vpc_id     = aws_vpc.main.id
  vpc_id     = local.vpc_id # call / reference the local
  cidr_block = var.subnet_cidr_2
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "private2"
  }
}

resource "aws_subnet" "private3" {
  ##vpc_id     = aws_vpc.main.id
  vpc_id     = local.vpc_id # call / reference the local
  cidr_block = var.subnet_cidr_3
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "private3"
  }
}

resource "aws_subnet" "private4" {
  ##vpc_id     = aws_vpc.main.id
  vpc_id     = local.vpc_id
  cidr_block = var.subnet_cidr_4 # call / reference the local
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "private4"
  }
}


## How do I reference a variable? it would be (var.variable name)
## Creating EC2
           # local_name      # resource_name
resource "aws_instance" "EC2_instance" {
  ami           = var.ami_id 
  instance_type = var.instance_type

  tags = {
    Name = "EC2_instance"
  }
}


## ECS Cluster
resource "aws_ecs_cluster" "ECS_cluster" {
  name = "ECS_cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

## ECS Task Definition (EC2/bridge mode)
resource "aws_ecs_task_definition" "service" {
  family                   = "service"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "first"
      image     = "service-first"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },
    {
      name      = "second"
      image     = "service-second"
      cpu       = 10
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 443
          hostPort      = 443
        }
      ]
    }
  ])

  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-1b, us-east-1c]"
  }
}

## ECS Service
resource "aws_ecs_service" "mongo" {
  name            = "mongodb"
  cluster         = aws_ecs_cluster.ECS_cluster.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 3
  launch_type     = "EC2"

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.mongo_tg.arn
    container_name   = "first"   # must match task definition
    container_port   = 80
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-1b, us-east-1c]"
  }

  depends_on = [
    aws_lb_listener.http
  ]
}

## ALB (using existing subnets)
resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = true
  load_balancer_type = "application"
  subnets            = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

## Target Group for ECS service
resource "aws_lb_target_group" "mongo_tg" {
  name        = "mongo-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = local.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

## Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.test.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mongo_tg.arn
  }
}

## ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

## DATA SOURCE BLOCK. 
## This block is used to pull down existing values or resource attributes from the console in a targeted provider (e.g AWS)
## How to pull down a resource using data source # -target to 

# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}





## LOCAL BLOCK.
## Local block is used to avoid or to remove redundancy


## MODULE BLOCK
## Modules are considered in Terraform as a blueprint of an infrastructure.