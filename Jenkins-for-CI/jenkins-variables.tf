variable "aws_region" {
  description = "AWS region for Jenkins ECS"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for Jenkins VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR for public subnet 1"
  type        = string
  default     = "10.20.10.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR for public subnet 2"
  type        = string
  default     = "10.20.11.0/24"
}

variable "az_1" {
  description = "Availability zone 1"
  type        = string
  default     = "us-east-1a"
}

variable "az_2" {
  description = "Availability zone 2"
  type        = string
  default     = "us-east-1b"
}

variable "jenkins_fargate_cpu" {
  description = "CPU units for Jenkins Fargate task"
  type        = number
  default     = 512
}

variable "jenkins_fargate_memory" {
  description = "Memory (MB) for Jenkins Fargate task"
  type        = number
  default     = 1024
}

variable "jenkins_admin_user" {
  description = "Initial Jenkins admin username"
  type        = string
  default     = "admin"
}

variable "jenkins_admin_pass" {
  description = "Initial Jenkins admin password"
  type        = string
  sensitive   = true
}



