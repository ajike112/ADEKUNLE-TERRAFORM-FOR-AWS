variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "Private subnets for ECS tasks and RDS"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnets for ALB"
  type        = list(string)
}


variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "db_password" {
  description = "Password for the SonarQube PostgreSQL database"
  type        = string
  sensitive   = true
}

