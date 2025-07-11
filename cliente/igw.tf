module "internet_gateway" {
  source      = "git::ssh://git@github.com/OrganizacionDevOps/Optimizapp_internet_Gateway_module.git?ref=main"
  
  vpc_id      = module.vpc.vpc_id
  client      = var.client
  environment = var.environment
  tags = {
    Project = "cliente-c"
  }
}
