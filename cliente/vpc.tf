module "vpc" {
  source        = "git::ssh://git@github.com/OrganizacionDevOps/OptimizApp_Infraestrucutra_Modular.git//modules/vpc?ref=main"
  
  vpc_name      = "${var.client_name}-${var.environment}-vpc"
  cidr_block    = var.vpc_cidr_block
  environment   = var.environment
  kms_key_id    = var.kms_key_id

  tags = {
    Client      = var.client_name
    Environment = var.environment
  }
}
