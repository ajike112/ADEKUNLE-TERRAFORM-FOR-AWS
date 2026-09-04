output "sonarqube_url" {
  value       = module.sonarqube_fargate.sonarqube_url
  description = "SonarQube ALB URL"
}

output "sonarqube_api_url" {
  value       = module.sonarqube_fargate.sonarqube_api_url
  description = "SonarQube API health endpoint"
}
