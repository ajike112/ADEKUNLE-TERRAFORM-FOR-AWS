# KMS key for ECR encryption
resource "aws_kms_key" "ecr_key" {
  description             = "KMS key for ECR image encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name        = "ecr-key"
    Environment = "ci"
  }
}



# Create ECR repository for Jenkins builds
resource "aws_ecr_repository" "jenkins_app_repo" {
  name                 = "jenkins-app-repo"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr_key.arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "jenkins-app-repo"
    Environment = "ci"
  }
}

# Lifecycle policy to keep last 20 images
resource "aws_ecr_lifecycle_policy" "jenkins_app_policy" {
  repository = aws_ecr_repository.jenkins_app_repo.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 20 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 20
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}
