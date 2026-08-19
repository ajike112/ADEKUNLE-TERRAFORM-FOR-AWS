output "jenkins_alb_dns_name" {
  description = "DNS name of the Jenkins ALB"
  value       = aws_lb.jenkins_alb.dns_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster hosting Jenkins"
  value       = aws_ecs_cluster.jenkins_cluster.arn
}
