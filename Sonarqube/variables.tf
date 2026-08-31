variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnets"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnets"
}

variable "ecs_cluster_name" {
  type        = string
  description = "ECS cluster name"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "db_password" {
  description = "Password for SonarQube PostgreSQL database"
  type        = string
  sensitive   = true
}
