
############################################
# Jenkins Agent EC2 Terraform Variables
############################################

# AWS Region
region = "us-east-1"

# VPC and networking
vpc_id        = "vpc-02c37a159008c6f80"
vpc_cidr      = "10.20.0.0/16"
subnet_cidr   = "10.20.60.0/24"
availability_zone = "us-east-1a"

# Ubuntu 22.04 LTS AMI
ami_id = "ami-0f8a61b66d1accaee"

# Instance type
instance_type = "t3.medium"

# Your EC2 key pair name
key_name = "Jenkins-CI keypair"

# Jenkins master public IPs / ALB IPs (JNLP)
jenkins_master_cidr = [
  "3.229.64.220/32",
  "3.217.210.219/32"
]

# Your own public IP for SSH access
ssh_cidr = "98.194.47.86/32"

# External Jenkins ECR policy ARN
jenkins_ecr_policy_arn = "arn:aws:iam::536697262404:policy/jenkins-ecr-push-policy"
