module "sonarqube_fargate" {
  source          = "./modules/sonarqube-fargate"
  vpc_id = "vpc-02c37a159008c6f80"

  private_subnets = [
    "subnet-0bfe282b39263fdc1",
    "subnet-03d8d7454176f15b1"
  ]

  public_subnets = [
    "subnet-067afa72f3ec1a4b4",
    "subnet-0db48ff22c23537fe"
  ]
  environment     = var.environment
  db_password     = var.db_password
}

# Discover Jenkins VPC and subnets by tags
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
