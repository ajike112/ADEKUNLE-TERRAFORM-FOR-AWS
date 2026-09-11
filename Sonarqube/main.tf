module "sonarqube_fargate" {
  source          = "./modules/sonarqube-fargate"

  vpc_id          = var.vpc_id
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  environment     = var.environment
  db_password     = var.db_password
}

# (Optional) keep these discovery data sources if you plan to use them later
data "aws_vpc" "jenkins" {
  filter {
    name   = "tag:Name"
    values = ["jenkins-vpc"]
  }
}

data "aws_subnets" "jenkins_private" {
  filter {
    name   = "tag:Tier"
    values = ["private"]
  }
}

data "aws_subnets" "jenkins_public" {
  filter {
    name   = "tag:Tier"
    values = ["public"]
  }
}
