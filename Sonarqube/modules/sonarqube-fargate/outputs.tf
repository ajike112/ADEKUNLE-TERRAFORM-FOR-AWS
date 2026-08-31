output "sonarqube_url" {
  description = "Public URL for SonarQube"
  value       = aws_lb.sonarqube_alb.dns_name
}

output "sonarqube_db_endpoint" {
  description = "RDS endpoint for SonarQube"
  value       = aws_db_instance.sonarqube_db.address
}
