
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

## outputs Block
output "private_dns" {
  description = "private dns id"
  value = aws_instance.EC2_instance.private_dns
}

## RESOURCE BLOCK. This block is to create a resource.

## Create VPC
resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

## Create Subnet
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr

  tags = {
    Name = "Main"
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

## DATA SOURCE BLOCK. 
## This block is used to pull down existing values or resource attributes from the console in a targeted provider (e.g AWS)

## LOCAL BLOCK.
## Local block is used to avoid or to remove redundancy