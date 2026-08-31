variable "region" {
  type        = string
  description = "AWS region"
}

variable "ami_id" {
  type        = string
  description = "AMI ID (Ubuntu 22.04 recommended)"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.medium"
}

variable "key_name" {
  type        = string
  description = "SSH key pair name"
}

variable "jenkins_master_cidr" {
  type        = list(string)
  description = "CIDR blocks for Jenkins master to connect (port 50000)"
}

variable "ssh_cidr" {
  type        = string
  description = "CIDR allowed for SSH access"
}
