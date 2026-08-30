# Production-Grade Jenkins on AWS ECS Fargate

## Overview
I deployed a production-grade Jenkins CI/CD environment on AWS using Terraform.
The architecture includes private compute, persistent EFS storage, secure IAM roles,
isolated networking, and a public Application Load Balancer. The entire setup is
modular, scalable, and fully reproducible using `terraform apply` and
`terraform destroy`.

---


### VPC & Networking
- Dedicated VPC (`10.20.0.0/16`)
- Public subnets for ALB
- Private subnets for ECS Fargate
- Internet Gateway + NAT Gateway
- Public and private route tables

### Security Groups
- **ALB SG**: inbound 80 from the world
- **Task SG**: inbound 8080 from ALB SG
- **EFS SG**: inbound 2049 from Task SG

### ECS Fargate (Compute)
- ECS cluster
- Fargate service running Jenkins LTS
- CloudWatch logging
- IAM execution + task roles

### EFS (Storage)
- Encrypted EFS filesystem
- Access point at `/jenkins`
- Mount targets in private subnets

### Load Balancer
- Application Load Balancer
- Target group (IP mode)
- Listener on port 80
- Health check path: `/login`

---

## Issues I Encountered & How I Solved Them

### 1. ALB Targets Unhealthy
**Cause:** Wrong SG passed into module  
**Fix:** Split SG variables into `alb_sg_id`, `task_sg_id`, `efs_sg_id`

### 2. EFS Mount Failure
**Cause:** EFS mount targets used ALB SG  
**Fix:** Created dedicated EFS SG allowing NFS only from Task SG

### 3. ALB Health Check Returning 403
**Cause:** Jenkins returns 403 on `/`  
**Fix:** Changed health check path to `/login`

### 4. Container Health Check Failing
**Cause:** Jenkins image lacks `curl`  
**Fix:** Removed container health check

### 5. Retrieving Jenkins Initial Admin Password
**Fix:** Used ECS Exec to read `/var/jenkins_home/secrets/initialAdminPassword`

---

## Final Result
I now have a production-grade Jenkins deployment on AWS ECS Fargate with:
- Private compute
- Public ALB
- Persistent EFS storage
- Secure IAM roles
- Isolated networking
- Automated provisioning via Terraform

This architecture is enterprise-ready and fully reproducible.

