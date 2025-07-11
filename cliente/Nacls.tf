module "nacls" {
  source             = "git::ssh://git@github.com/OrganizacionDevOps/Optimizapp_NACLs_module.git?ref=main"
  vpc_id             = module.vpc.vpc_id
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnet_ids  = module.subnets.public_subnet_ids
  private_subnet_ids = module.subnets.private_subnet_ids
  client_name        = var.client_name
  environment        = var.environment
  tags = {
    Project = "cliente-c"
  }
}