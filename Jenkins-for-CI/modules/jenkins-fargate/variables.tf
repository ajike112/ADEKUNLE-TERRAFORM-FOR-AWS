variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for Jenkins"
}



variable "alb_sg_id" {
  type        = string
  description = "Security group ID for the ALB"
}

variable "task_sg_id" {
  type        = string
  description = "Security group ID for Jenkins ECS tasks"
}

variable "efs_sg_id" {
  type        = string
  description = "Security group ID for EFS mount targets"
}


variable "jenkins_fargate_cpu" {
  type        = number
  description = "CPU units for Jenkins Fargate task"
}

variable "jenkins_fargate_memory" {
  type        = number
  description = "Memory (MB) for Jenkins Fargate task"
}

variable "jenkins_admin_user" {
  type        = string
  description = "Initial Jenkins admin username"
}

variable "jenkins_admin_pass" {
  type        = string
  description = "Initial Jenkins admin password"
  sensitive   = true
}

variable "private_subnet_ids" {
  type = map(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}
