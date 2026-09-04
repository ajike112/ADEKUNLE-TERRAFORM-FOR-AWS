resource "aws_secretsmanager_secret" "db_password" {
  name        = "sonarqube-db-password-${var.environment}-v2"
  description = "Password for SonarQube PostgreSQL database"

  lifecycle {
    prevent_destroy = true
  }

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "db_password_value" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
}
