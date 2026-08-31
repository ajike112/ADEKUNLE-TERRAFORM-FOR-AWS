output "sonarqube_url" {
  value       = module.sonarqube_fargate.sonarqube_url
  description = "SonarQube ALB URL"
}
