output "jenkins_url" {
  description = "Public URL for Jenkins (ALB DNS)"
  value       = module.jenkins_fargate.jenkins_alb_dns_name
}

output "jenkins_cluster_arn" {
  description = "ECS cluster ARN hosting Jenkins"
  value       = module.jenkins_fargate.ecs_cluster_arn
}

output "ecr_repository_url" {
  description = "Full ECR repository URL for Jenkins builds"
  value       = aws_ecr_repository.jenkins_app_repo.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the Jenkins ECR repository"
  value       = aws_ecr_repository.jenkins_app_repo.arn
}

output "jenkins_task_role_name" {
  value = module.jenkins_fargate.jenkins_task_role_name
}

output "jenkins_task_role_arn" {
  value = module.jenkins_fargate.jenkins_task_role_arn
}

output "ecr_kms_key_arn" {
  description = "ARN of the KMS key used for ECR encryption"
  value       = aws_kms_key.ecr_key.arn
}
