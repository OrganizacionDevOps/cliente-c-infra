module "nat_gateway" {
  source          = "git::ssh://git@github.com/OrganizacionDevOps/Optimizapp_NAT_Gateway_module.git?ref=main"
  client_name     = var.client_name
  environment     = var.environment
  public_subnet_id= module.subnets.public_subnet_ids[0]
  tags = {
    Project = "cliente-c"
  }
}