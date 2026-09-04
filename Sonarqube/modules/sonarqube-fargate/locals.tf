locals {
  prefix = "sonarqube-${var.environment}"

  tags = {
    Project     = "SonarQube"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "Adekunle"
  }
}

data "aws_region" "current" {}
