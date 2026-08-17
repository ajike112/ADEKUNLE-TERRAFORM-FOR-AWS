
##############################
## NEW ADDITION
##############################

variable "cluster_endpoint" {
  type        = string
  description = "EKS cluster API endpoint"
}

variable "cluster_ca" {
  type        = string
  description = "EKS cluster CA certificate"
}

variable "cluster_token" {
  type        = string
  description = "Authentication token for EKS cluster"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "alb_controller_role_arn" {
  type         = string
  description = "IAM role ARN for ALB controller"
}

