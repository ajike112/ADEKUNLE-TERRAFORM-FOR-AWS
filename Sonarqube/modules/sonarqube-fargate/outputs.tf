output "sonarqube_url" {
  description = "Public URL for SonarQube"
  value       = aws_lb.sonarqube_alb.dns_name
}

output "sonarqube_api_url" {
  description = "SonarQube API health endpoint"
  value       = "http://${aws_lb.sonarqube_alb.dns_name}/api/system/status"
}

output "sonarqube_db_endpoint" {
  description = "RDS endpoint for SonarQube"
  value       = aws_db_instance.sonarqube_db.address
}

output "sonarqube_db_secret_arn" {
  description = "Secrets Manager ARN for SonarQube DB password"
  value       = aws_secretsmanager_secret.db_password.arn
}
