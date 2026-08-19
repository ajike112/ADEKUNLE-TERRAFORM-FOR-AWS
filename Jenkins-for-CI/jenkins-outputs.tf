output "jenkins_url" {
  description = "Public URL for Jenkins (ALB DNS)"
  value       = module.jenkins_fargate.jenkins_alb_dns_name
}

output "jenkins_cluster_arn" {
  description = "ECS cluster ARN hosting Jenkins"
  value       = module.jenkins_fargate.ecs_cluster_arn
}
