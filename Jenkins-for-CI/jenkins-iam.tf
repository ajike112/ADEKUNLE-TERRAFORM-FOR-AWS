# Jenkins ECS task role (already exists, just attach ECR policy)
# Reference Jenkins ECS task role
locals {
  jenkins_task_role_name = module.jenkins_fargate.jenkins_task_role_name
}

# Policy for Jenkins to push Docker images to ECR
resource "aws_iam_policy" "jenkins_ecr_push_policy" {
  name        = "jenkins-ecr-push-policy"
  description = "Allow Jenkins ECS task to push images to ECR"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach policy to Jenkins ECS task role
resource "aws_iam_role_policy_attachment" "jenkins_ecr_attach" {
  role       = local.jenkins_task_role_name
  policy_arn = aws_iam_policy.jenkins_ecr_push_policy.arn
}
