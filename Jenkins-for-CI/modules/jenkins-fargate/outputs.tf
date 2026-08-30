output "jenkins_alb_dns_name" {
  description = "DNS name of the Jenkins ALB"
  value       = aws_lb.jenkins_alb.dns_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster hosting Jenkins"
  value       = aws_ecs_cluster.jenkins_cluster.arn
}

output "jenkins_task_role_name" {
  description = "The ECS task role used by Jenkins"
  value       = aws_iam_role.jenkins_task_role.name
}

output "jenkins_task_role_arn" {
  description = "The ARN of the Jenkins ECS task role"
  value       = aws_iam_role.jenkins_task_role.arn
}

