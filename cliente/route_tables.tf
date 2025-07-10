module "route_tables" {
  source             = "git::ssh://git@github.com/OrganizacionDevOps/Optimizapp_route_tables_module.git?ref=main"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.subnets.public_subnet_ids
  private_subnet_ids = module.subnets.private_subnet_ids
  environment        = var.environment
}
