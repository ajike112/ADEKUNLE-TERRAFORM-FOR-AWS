module "sonarqube_fargate" {
  source          = "./modules/sonarqube-fargate"
  vpc_id          = var.vpc_id
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  environment     = var.environment
  db_password     = var.db_password
}
