############################################
# Jenkins Agent EC2 Terraform Variables
############################################

# AWS Region
region = "us-east-1"

# Ubuntu 22.04 LTS AMI
ami_id = "ami-0f8a61b66d1accaee"

# Instance type
instance_type = "t3.medium"

# Your EC2 key pair name
key_name = "Jenkins-CI keypair"

# Jenkins master public IPs / ALB IPs
jenkins_master_cidr = [
  "3.229.64.220/32",
  "3.217.210.219/32"
]

# Your own public IP for SSH access
ssh_cidr = "98.194.47.86/32"
