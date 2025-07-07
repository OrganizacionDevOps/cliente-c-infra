module "vpc" {
  source = "git::https://github.com/OrganizacionDevOps/OptimizApp_Infraestrucutra_Modular.git//modules/networking/vpc?ref=main"

  client_name  = var.client_name
  environment  = var.environment
  region       = var.region

  cidr_block   = var.vpc_cidr_block
  enable_nat   = var.enable_nat_gateway
  enable_dns   = var.enable_dns_support

  tags = {
    Client      = var.client_name
    Environment = var.environment
  }
}
