
variable "aws_region" {
  description = "AWS region for Jenkins ECS"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for Jenkins VPC"
  type        = string
}

variable "public_subnet_1_cidr" {
  description = "CIDR for public subnet 1"
  type        = string
}

variable "public_subnet_2_cidr" {
  description = "CIDR for public subnet 2"
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "CIDR for private subnet 1"
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "CIDR for private subnet 2"
  type        = string
}

variable "az_1" {
  description = "Availability zone 1"
  type        = string
}

variable "az_2" {
  description = "Availability zone 2"
  type        = string
}

variable "jenkins_fargate_cpu" {
  description = "CPU units for Jenkins Fargate task"
  type        = number
}

variable "jenkins_fargate_memory" {
  description = "Memory (MB) for Jenkins Fargate task"
  type        = number
}

variable "jenkins_admin_user" {
  description = "Initial Jenkins admin username"
  type        = string
}

variable "jenkins_admin_pass" {
  description = "Initial Jenkins admin password"
  type        = string
  sensitive   = true
}

variable "task_role_policy_arn" {
  description = "IAM policy ARN attached to Jenkins task role"
  type        = string
}

variable "execution_role_policy_arn" {
  description = "IAM policy ARN attached to Jenkins execution role"
  type        = string
}