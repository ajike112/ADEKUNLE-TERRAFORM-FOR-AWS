
variable "region" {
  type        = string
  description = "AWS region"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where Jenkins agent will be deployed"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR range of the VPC (used for internal SG rules)"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR block for Jenkins agent subnet"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone for Jenkins agent subnet"
}

variable "ami_id" {
  type        = string
  description = "AMI ID (Ubuntu 22.04 recommended)"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "key_name" {
  type        = string
  description = "SSH key pair name"
}

variable "jenkins_master_cidr" {
  type        = list(string)
  description = "CIDR blocks for Jenkins master / ALB to connect (port 50000)"
}

variable "ssh_cidr" {
  type        = string
  description = "Laptop IP for SSH"
}

variable "jenkins_ecr_policy_arn" {
  type        = string
  description = "ARN of the Jenkins ECR push IAM policy"
}
